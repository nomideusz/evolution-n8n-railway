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
    S3_ENABLED=true \
    S3_PORT=443 \
    S3_USE_SSL=true \
    S3_REGION=auto \
    S3_ENDPOINT=t3.storageapi.dev
# S3_ENDPOINT is the Railway bucket endpoint HOST (no scheme). Override the
# service variable if your bucket's credentials show a different host.
