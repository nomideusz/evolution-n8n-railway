# Deploy and Host Evolution API + n8n on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/zRUAKb?utm_medium=integration&utm_source=button&utm_campaign=evolution-n8n)

[Evolution API](https://evolution-api.com/) is an open-source WhatsApp REST API: connect numbers via QR code or the official WhatsApp Business API, send and receive messages, media, buttons, and group events — and [n8n](https://n8n.io/) is the workflow automation platform that turns those messages into bots, funnels, and integrations with 400+ services. Together they are the standard self-hosted WhatsApp automation stack.

## About Hosting Evolution API + n8n

This template runs the full automation stack as four Railway services wired over private networking: Evolution API v2.3.7 and n8n each with their own public domain, plus one PostgreSQL instance serving both apps (separate `evolution` and `n8n` databases via init script) and Redis for Evolution's cache. WhatsApp media goes to a **Railway bucket over S3** instead of filling a volume, session credentials persist in Postgres and a small instance volume (no re-pairing on redeploys), and the Redis URI carries `?family=0` — the fix for the ioredis IPv6 incompatibility with Railway's private networking that breaks naive templates. Open Evolution's `/manager` UI with your generated API key, pair a number, then point a webhook at an n8n workflow.

## Common Use Cases

- WhatsApp chatbots and AI agents: incoming messages trigger n8n workflows (LLM calls, CRM lookups) that reply through Evolution
- Notification and messaging funnels: order confirmations, appointment reminders, abandoned-cart flows into WhatsApp
- Multi-number customer service: manage several WhatsApp instances from one API with message history in Postgres

## Dependencies for Evolution API + n8n Hosting

- All bundled: PostgreSQL 16, Redis 7, and a Railway bucket for media are provisioned by the template
- A phone with WhatsApp to pair via QR code (or official WhatsApp Business API credentials)

### Deployment Dependencies

- [Evolution API documentation](https://doc.evolution-api.com/)
- [n8n documentation](https://docs.n8n.io/)
- [Template source on GitHub](https://github.com/nomideusz/evolution-n8n-railway)

### Implementation Details

**Evolution's manager UI is at the `evolution` service's domain + `/manager`** — sign in with the `AUTHENTICATION_API_KEY` variable's value (auto-generated). **n8n is at the `n8n` service's domain** — first visit creates the owner account.

Service map:

| Service | Image | Role |
|---|---|---|
| evolution | `evoapicloud/evolution-api:v2.3.7` | WhatsApp REST API + manager UI, public domain |
| n8n | `n8nio/n8n:2.29.10` | Workflow automation, public domain, volume at `/home/node/.n8n` |
| postgres | `postgres:16-alpine` | Both apps' data (`evolution` + `n8n` DBs), on a volume |
| redis | `redis:7-alpine` | Evolution cache (instance state, sessions) |

Variable wiring (lives in the template composer; documented here for maintenance):

- **evolution**: `AUTHENTICATION_API_KEY` (generated), `SERVER_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}`, `DATABASE_CONNECTION_URI=postgresql://postgres:${{postgres.POSTGRES_PASSWORD}}@${{postgres.RAILWAY_PRIVATE_DOMAIN}}:5432/evolution?schema=evolution_api`, `CACHE_REDIS_URI=redis://:${{redis.REDIS_PASSWORD}}@${{redis.RAILWAY_PRIVATE_DOMAIN}}:6379/6?family=0` (the `family=0` suffix is required — ioredis defaults to IPv4 and Railway private DNS is IPv6-only), `S3_ENABLED=true`, `S3_ACCESS_KEY`/`S3_SECRET_KEY`/`S3_BUCKET` (Railway bucket), `S3_ENDPOINT` (bucket endpoint host, no scheme), `S3_PORT=443`, `S3_USE_SSL=true`, `S3_REGION=auto`; volume at `/evolution/instances`
- **n8n**: `N8N_ENCRYPTION_KEY` (generated), `DB_POSTGRESDB_HOST=${{postgres.RAILWAY_PRIVATE_DOMAIN}}`, `DB_POSTGRESDB_USER=postgres`, `DB_POSTGRESDB_PASSWORD=${{postgres.POSTGRES_PASSWORD}}`, `N8N_HOST=${{RAILWAY_PUBLIC_DOMAIN}}`, `WEBHOOK_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}/`, `PORT=5678` as an explicit service variable (Railway injects `PORT=8080` at runtime, overriding image ENV), and `RAILWAY_RUN_UID=0` — the n8n image runs as user `node` but Railway volumes mount root-owned, so without it n8n crash-loops on `EACCES /home/node/.n8n/config`; volume at `/home/node/.n8n`
- **postgres**: `POSTGRES_PASSWORD` (generated); volume at `/var/lib/postgresql/data`
- **redis**: `REDIS_PASSWORD` (generated)

Notes and limits:

- Evolution → n8n webhooks travel over n8n's public domain (that URL must be public for the n8n editor's test mode anyway); n8n → Evolution API calls can use `http://evolution.railway.internal:8080` to skip egress fees.
- WhatsApp pairing state survives redeploys (Postgres + instance volume). Deleting the postgres volume means re-pairing every number.
- Unofficial WhatsApp Web instances (QR pairing, via Baileys) can be banned by Meta for spam-like behavior — use the official Business API integration for high-volume sending.
- n8n runs single-process here (no queue mode); add workers + a queue-mode Redis if you push past hundreds of executions per minute.

## Why Deploy Evolution API + n8n on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Evolution API + n8n on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
