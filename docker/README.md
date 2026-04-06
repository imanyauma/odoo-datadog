# Docker setup for Odoo 17

## 1) Prepare environment variables

Copy `.env.example` to `.env` and adjust values:

- POSTGRES_DB
- POSTGRES_USER
- POSTGRES_PASSWORD
- ODOO_HTTP_PORT
- ODOO_LONGPOLLING_PORT

## 2) Build and start

```bash
docker compose up -d --build
```

## 3) Access Odoo

Open http://localhost:8069 in your browser.

## 4) Stop services

```bash
docker compose down
```

## Notes

- Odoo source is mounted from `./addons` into the container for easy module development.
- Persistent data is stored in Docker volumes: `postgres_data`, `odoo_data`, and `odoo_logs`.
