# Built in github.com/two-workspaces/evolution: Evolution API v2.3.7 behind a start script that
# waits for Postgres and Redis, refuses the image's public default API key, restarts the API
# if it dies, and serves the manager's logo locally (upstream's logo URLs answer 404).
# The upstream version pin lives in that repo. New deploys of the template pull this image
# directly; this Dockerfile keeps deployments that build from this repo on the same image.
# upgrade: skip
FROM ghcr.io/two-workspaces/evolution:065f2b1

# Messages, chats and the instance credentials live in Postgres (DATABASE_SAVE_DATA_*).
# WhatsApp's encryption keys live in Redis, so Redis needs a volume at /data: without one,
# a Redis restart leaves paired numbers unable to decrypt messages.
ENV SERVER_TYPE=http \
    SERVER_PORT=8080 \
    DATABASE_ENABLED=true \
    DATABASE_PROVIDER=postgresql \
    DATABASE_SAVE_DATA_INSTANCE=true \
    DATABASE_SAVE_DATA_NEW_MESSAGE=true \
    DATABASE_SAVE_MESSAGE_UPDATE=true \
    DATABASE_SAVE_DATA_CONTACTS=true \
    DATABASE_SAVE_DATA_CHATS=true \
    DATABASE_SAVE_DATA_LABELS=true \
    DATABASE_SAVE_DATA_HISTORIC=true \
    CACHE_REDIS_ENABLED=true \
    CACHE_REDIS_PREFIX_KEY=evolution \
    CACHE_REDIS_SAVE_INSTANCES=false \
    DEL_INSTANCE=false \
    LANGUAGE=en \
    S3_ENABLED=false \
    S3_PORT=443 \
    S3_USE_SSL=true
# S3 is off by default: Evolution's minio client calls listBuckets/makeBucket
# at boot, which Railway's single-bucket-scoped credentials can't satisfy.
# Without S3, media is delivered by webhook and API but not stored. For external S3-compatible storage,
# set S3_ENABLED=true plus S3_ENDPOINT (host, no scheme), S3_ACCESS_KEY,
# S3_SECRET_KEY, S3_BUCKET, S3_REGION as service variables.
