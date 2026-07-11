FROM evoapicloud/evolution-api:v2.3.7

# Persistence lives in Postgres (DATABASE_SAVE_DATA_*) and media in the
# Railway bucket; instance session files still land here, so a small volume
# at /evolution/instances survives redeploys without re-pairing WhatsApp.
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
# Media persists in Postgres instead. To use external S3-compatible storage,
# set S3_ENABLED=true plus S3_ENDPOINT (host, no scheme), S3_ACCESS_KEY,
# S3_SECRET_KEY, S3_BUCKET, S3_REGION as service variables.
