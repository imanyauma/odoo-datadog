#!/bin/sh
set -e

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-5432}"

if [ "${WAIT_FOR_DB:-true}" = "true" ]; then
    echo "Waiting for PostgreSQL at ${DB_HOST}:${DB_PORT}..."
    until pg_isready -h "${DB_HOST}" -p "${DB_PORT}" >/dev/null 2>&1; do
        sleep 1
    done
fi

exec "$@"
