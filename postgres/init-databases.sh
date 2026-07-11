#!/bin/bash
set -e

# Runs once on first boot (empty PGDATA). POSTGRES_DB already created
# `evolution`; n8n expects its own database to exist.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE DATABASE n8n;
EOSQL
