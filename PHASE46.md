# Phase 46 — task_events SSE demo hardening

## Goal
Make Phase 45 repeatable + demo-safe: one command proves the task_events SSE stream works and that prior cursor/query failures are gone.

## Endpoints
- Canonical: `GET /events/task-events` (SSE stream)
- Alias: `GET /api/task-events-sse` → `307` redirect to `/events/task-events`

## Cursor semantics
- Cursor is **milliseconds since epoch** derived from `created_at`.
- On first connect, cursor seeds from `max(created_at)` (ms) to avoid dumping the full table.
- Polling query uses: `created_at > to_timestamp($1 / 1000.0)` ordered by `created_at asc`.
- Cursor advances by observed `created_at` ms (not by `id`).

## Smoke
Run:
- `./scripts/phase46_task_events_sse_smoke.sh`

It verifies:
1) Alias returns 307 + correct Location  
2) Canonical endpoint emits `event: hello` quickly  
3) Postgres logs do **not** include historical failure signatures (uuid/blank created_at/order/max issues)
