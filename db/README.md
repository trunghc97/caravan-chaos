# Caravan Chaos Database

PostgreSQL schema and migrations for durable room, player, event log, and snapshot data.

## Local Database

The root `docker-compose.yml` starts Postgres and Redis for backend development.

## Migrations

Initial schema lives in `migrations/000001_core_schema.sql`.
