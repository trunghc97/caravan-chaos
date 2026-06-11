# Caravan Chaos

Monorepo for a mobile race-betting game set on a fantasy desert trade route.

## Structure

- `mobile/` - Flutter app and plain Dart game rules.
- `backend/` - Go API and realtime service scaffold.
- `db/` - PostgreSQL migrations and schema notes.
- `docs/` - architecture notes, including `docs/BACKEND_PLAN.md`.
- `prototype-web/` - legacy HTML prototype kept for reference.

## Mobile

```sh
cd mobile
flutter pub get
flutter run
```

Tests:

```sh
cd mobile
flutter test
```

## Backend

```sh
cd backend
go run ./cmd/server
```

The backend currently exposes `GET /healthz` plus room/realtime stubs that match the planned server-authoritative direction.

## Database

Start local dependencies from the repo root:

```sh
docker compose up -d postgres redis
```

Initial schema lives in `db/migrations/000001_core_schema.sql`.

## Backend Direction

See `docs/BACKEND_PLAN.md`. Recommended v1 stack: Flutter client, Go backend, WebSocket realtime, PostgreSQL for durable game records, Redis for presence and horizontal pub/sub when scaling beyond one instance.
