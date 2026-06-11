# Caravan Chaos

Monorepo for a mobile race-betting game set on a fantasy desert trade route.

## Structure

- `mobile/` - Flutter app and plain Dart game rules for MVP1 local solo.
- `backend/` - Go API and realtime service scaffold.
- `db/` - PostgreSQL migrations and schema notes.
- `docs/` - architecture notes, including `docs/BACKEND_PLAN.md` and `docs/MVP1.md`.
- `prototype-web/` - legacy HTML prototype kept for reference.

## Prerequisites

- Flutter 3.13+ with Dart 3.1+.
- Go 1.22+.
- Docker Desktop or compatible `docker compose` for local Postgres and Redis.

## Quick Start

From the repo root:

```sh
docker compose up -d postgres redis
```

Start the backend:

```sh
cd backend
go run ./cmd/server
```

In another terminal, start the Flutter app:

```sh
cd mobile
flutter pub get
flutter run
```

The backend listens on `http://localhost:8080` by default. Check it with:

```sh
curl http://localhost:8080/healthz
```

## Run Mobile Only

MVP1 is playable offline as a Flutter-only solo prototype.

```sh
cd mobile
flutter pub get
flutter run
```

Run mobile checks:

```sh
cd mobile
flutter analyze
flutter test
```

## Run Backend Only

```sh
cd backend
go run ./cmd/server
```

Environment variables:

- `HTTP_ADDR`, default `:8080`.
- `DATABASE_URL`, default `postgres://caravan:caravan@localhost:5432/caravan_chaos?sslmode=disable`.
- `REDIS_ADDR`, default `localhost:6379`.

Run backend tests:

```sh
cd backend
GOMAXPROCS=1 go test -p 1 ./...
```

## Database

Local services are defined in `docker-compose.yml`.

```sh
docker compose up -d postgres redis
docker compose down
```

Initial schema is loaded from `db/migrations/000001_core_schema.sql` when the Postgres volume is first created. To reset local database state:

```sh
docker compose down -v
docker compose up -d postgres redis
```

## Current MVP

MVP1 is local solo. See `docs/MVP1.md`.

Backend direction and future realtime architecture are documented in `docs/BACKEND_PLAN.md`.
