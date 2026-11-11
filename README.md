# Deploy and Host Evolution API + n8n on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/evolution-n8n?referralCode=sLjDXb&utm_medium=integration&utm_source=button&utm_campaign=evolution-n8n)

[Evolution API](https://evolution-api.com/) is an open-source WhatsApp REST API: connect numbers via QR code or the official WhatsApp Business API, send and receive messages, media, buttons, and group events — and [n8n](https://n8n.io/) is the workflow automation platform that turns those messages into bots, funnels, and integrations with 400+ services. Together they are the standard self-hosted WhatsApp automation stack.

## About Hosting Evolution API + n8n

This template runs the full automation stack as four Railway services wired over private networking: Evolution API v2.3.7 and n8n each with their own public domain, plus one PostgreSQL instance serving both apps (separate `evolution` and `n8n` databases via init script) and Redis, which holds WhatsApp's encryption keys on its own volume. Messages, chats and instance credentials persist in Postgres, so a paired number survives restarts and redeploys of every service (no re-pairing), and the Redis URI carries `?family=0` — the fix for the ioredis IPv6 incompatibility with Railway's private networking that breaks naive templates. Open Evolution's `/manager` UI with your generated API key, pair a number, then point a webhook at an n8n workflow.

## Common Use Cases

- WhatsApp chatbots and AI agents: incoming messages trigger n8n workflows (LLM calls, CRM lookups) that reply through Evolution
- Notification and messaging funnels: order confirmations, appointment reminders, abandoned-cart flows into WhatsApp
- Multi-number customer service: manage several WhatsApp instances from one API with message history in Postgres

## Dependencies for Evolution API + n8n Hosting

- All bundled: PostgreSQL 16 and Redis 7 are provisioned by the template
- A phone with WhatsApp to pair via QR code (or official WhatsApp Business API credentials)

### Deployment Dependencies

- [Evolution API documentation](https://doc.evolution-api.com/)
- [n8n documentation](https://docs.n8n.io/)
- [Template source on GitHub](https://github.com/two-workspaces/evolution-n8n)

### Implementation Details

**Evolution's manager UI is at the `evolution` service's domain + `/manager`** — sign in with the `AUTHENTICATION_API_KEY` variable's value (auto-generated). **n8n is at the `n8n` service's domain** — first visit creates the owner account.

Service map:

| Service | Image | Role |
|---|---|---|
| evolution | `ghcr.io/two-workspaces/evolution` (Evolution API v2.3.7, [source](https://github.com/two-workspaces/evolution)) | WhatsApp REST API + manager UI, public domain |
| n8n | `n8nio/n8n:2.47.4` | Workflow automation, public domain, volume at `/home/node/.n8n` |
| postgres | `postgres:16-alpine` | Both apps' data (`evolution` + `n8n` DBs), on a volume |
| redis | `redis:7-alpine` | Evolution's cache and WhatsApp encryption keys, append-only file on a volume at `/data` |

Variable wiring (lives in the template composer; documented here for maintenance):

- **evolution**: `AUTHENTICATION_API_KEY` (generated), `SERVER_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}`, `DATABASE_CONNECTION_URI=postgresql://postgres:${{postgres.POSTGRES_PASSWORD}}@${{postgres.RAILWAY_PRIVATE_DOMAIN}}:5432/evolution?schema=evolution_api`, `CACHE_REDIS_URI=redis://:${{redis.REDIS_PASSWORD}}@${{redis.RAILWAY_PRIVATE_DOMAIN}}:6379/6?family=0` (the `family=0` suffix is required — ioredis defaults to IPv4 and Railway private DNS is IPv6-only); volume at `/evolution/instances`
- **n8n**: `N8N_ENCRYPTION_KEY` (generated), `DB_POSTGRESDB_HOST=${{postgres.RAILWAY_PRIVATE_DOMAIN}}`, `DB_POSTGRESDB_USER=postgres`, `DB_POSTGRESDB_PASSWORD=${{postgres.POSTGRES_PASSWORD}}`, `N8N_HOST=${{RAILWAY_PUBLIC_DOMAIN}}`, `WEBHOOK_URL=https://${{RAILWAY_PUBLIC_DOMAIN}}/`, `PORT=5678` as an explicit service variable (Railway injects `PORT=8080` at runtime, overriding image ENV), and `RAILWAY_RUN_UID=0` — the n8n image runs as user `node` but Railway volumes mount root-owned, so without it n8n crash-loops on `EACCES /home/node/.n8n/config`; volume at `/home/node/.n8n`
- **postgres**: `POSTGRES_PASSWORD` (generated); volume at `/var/lib/postgresql/data`
- **redis**: `REDIS_PASSWORD` (generated); volume at `/data`

Notes and limits:

- Media is not stored (`S3_ENABLED=false`); it reaches you through webhooks and the API. Evolution's S3 client needs `listBuckets`/`makeBucket` at boot, which Railway's single-bucket-scoped credentials can't satisfy. To store media, point it at external S3-compatible storage: set `S3_ENABLED=true`, `S3_ENDPOINT` (host, no scheme), `S3_ACCESS_KEY`, `S3_SECRET_KEY`, `S3_BUCKET`, `S3_REGION` on the `evolution` service.
- Evolution → n8n webhooks travel over n8n's public domain (that URL must be public for the n8n editor's test mode anyway); n8n → Evolution API calls can use `http://evolution.railway.internal:8080` to skip egress fees.
- WhatsApp pairing state survives redeploys: credentials in Postgres, encryption keys in Redis. Deleting either volume means pairing every number again.
- **Deployed before 10 November 2026?** Your `redis` service has no volume, so a Redis restart or redeploy loses the encryption keys: messages can then fail to decrypt and numbers may need pairing again. To fix it, attach a volume mounted at `/data` to the `redis` service. Attaching it restarts Redis one last time without the keys, so check your numbers afterwards and pair again if needed.
- Unofficial WhatsApp Web instances (QR pairing, via Baileys) can be banned by Meta for spam-like behavior — use the official Business API integration for high-volume sending.
- n8n runs single-process here (no queue mode); add workers + a queue-mode Redis if you push past hundreds of executions per minute.

## Why Deploy Evolution API + n8n on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying Evolution API + n8n on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
