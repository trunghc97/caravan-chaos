# Caravan Chaos Backend

Go scaffold for the future server-authoritative realtime service.

## Run

```sh
go run ./cmd/server
```

## Environment

- `HTTP_ADDR`, default `:8080`
- `DATABASE_URL`, default local Postgres from the root Docker Compose file
- `REDIS_ADDR`, default `localhost:6379`

## Current Scope

- `GET /healthz` returns process health.
- `POST /v1/rooms` is a room creation stub.
- `GET /v1/realtime` is a WebSocket transport stub.
