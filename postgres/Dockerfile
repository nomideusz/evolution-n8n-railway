# One Postgres serves both apps: `evolution` and `n8n` databases (init script).
FROM postgres:16-alpine

# PGDATA one level below the mount: Railway volumes arrive with lost+found,
# which initdb refuses to initialize into.
ENV POSTGRES_USER=postgres \
    POSTGRES_DB=evolution \
    PGDATA=/var/lib/postgresql/data/pgdata

COPY init-databases.sh /docker-entrypoint-initdb.d/init-databases.sh
