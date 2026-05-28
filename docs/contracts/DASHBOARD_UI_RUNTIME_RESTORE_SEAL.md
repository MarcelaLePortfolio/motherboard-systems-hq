
# Dashboard UI Runtime Restore Seal

## Status

Dashboard runtime restoration is confirmed after Docker reset and fresh Postgres bootstrap.

## Validated Surfaces

- Docker runtime is clean and rebuilt.

- Postgres container is running.

- Dashboard container is running on `localhost:8080`.

- Dashboard root returns `200 OK`.

- Static dashboard assets return `200 OK`.

- `/api/tasks/health` returns `200 OK`.

- `/api/tasks?limit=12` returns `ok:true`.

- `/events/artifacts` connects as SSE.

- `/events/task-events` connects as SSE and emits heartbeat without the prior missing `kind` column error.

- Governed planning dry-run route remains live-valid and planning-only.

## Fresh DB Compatibility Repair

Because Docker reset recreated an empty Postgres volume, the minimal fresh schema initially lacked legacy dashboard-facing `task_events` compatibility columns.

The repaired compatibility columns are:

- `kind`

- `run_id`

- `actor`

- `ts`

This repair restores the dashboard task-events SSE contract without granting mutation, shell execution, autonomous execution, PM2 mutation, recursive delegation, or legacy `run_shell` promotion.

## Boundary

This seal confirms dashboard/runtime reconstruction only.

It does not restore historical Docker-only Postgres rows lost with the corrupted Docker volume.

It does not authorize new execution authority.

