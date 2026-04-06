#!/bin/sh
set -eu

# PostgreSQL runs scripts in /docker-entrypoint-initdb.d only on first init.
# This script ensures both roles exist and have expected passwords/privileges.
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
DO
\$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'postgres') THEN
        CREATE ROLE postgres WITH LOGIN SUPERUSER PASSWORD '${POSTGRES_PASSWORD}';
    ELSE
        ALTER ROLE postgres WITH LOGIN SUPERUSER PASSWORD '${POSTGRES_PASSWORD}';
    END IF;
END
\$\$;

DO
\$\$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'odoo') THEN
        CREATE ROLE odoo WITH LOGIN CREATEDB PASSWORD '${ODOO_DB_PASSWORD}';
    ELSE
        ALTER ROLE odoo WITH LOGIN CREATEDB PASSWORD '${ODOO_DB_PASSWORD}';
    END IF;
END
\$\$;
EOSQL
