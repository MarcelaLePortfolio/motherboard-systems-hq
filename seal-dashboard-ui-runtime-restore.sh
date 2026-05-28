
#!/usr/bin/env bash

set -euo pipefail

OUTPUT="DASHBOARD_UI_RUNTIME_RESTORE_SEAL.txt"

mkdir -p docs/contracts

cat > docs/contracts/DASHBOARD_UI_RUNTIME_RESTORE_SEAL.md << 'DOC'

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

DOC

rm -f "$OUTPUT"

echo "===== DASHBOARD UI RUNTIME RESTORE SEAL =====" | tee "$OUTPUT"

date | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== CURRENT HEAD =====" | tee -a "$OUTPUT"

git log --oneline -6 | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== COMPOSE PS =====" | tee -a "$OUTPUT"

docker compose ps | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== DASHBOARD ROOT =====" | tee -a "$OUTPUT"

curl -I http://localhost:8080/ 2>&1 | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== TASKS HEALTH =====" | tee -a "$OUTPUT"

curl -i http://localhost:8080/api/tasks/health 2>&1 | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== TASKS API =====" | tee -a "$OUTPUT"

curl -sS 'http://localhost:8080/api/tasks?limit=12' 2>&1 | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== TASK EVENTS SSE TIMEBOXED =====" | tee -a "$OUTPUT"

curl -i --max-time 2 http://localhost:8080/events/task-events 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== ARTIFACTS SSE TIMEBOXED =====" | tee -a "$OUTPUT"

curl -i --max-time 2 http://localhost:8080/events/artifacts 2>&1 | tee -a "$OUTPUT" || true

echo "" | tee -a "$OUTPUT"

echo "===== GOVERNED ROUTE RAW CHECK =====" | tee -a "$OUTPUT"

curl -sS -X POST http://localhost:8080/api/governed-planning/dry-run -H "Content-Type: application/json" --data @server/execution/smoke-test-governed-route-payload.json 2>&1 | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== SEAL DOC =====" | tee -a "$OUTPUT"

cat docs/contracts/DASHBOARD_UI_RUNTIME_RESTORE_SEAL.md | tee -a "$OUTPUT"

echo "" | tee -a "$OUTPUT"

echo "===== WORKTREE =====" | tee -a "$OUTPUT"

git status --short | tee -a "$OUTPUT"

git add seal-dashboard-ui-runtime-restore.sh DASHBOARD_UI_RUNTIME_RESTORE_SEAL.txt docs/contracts/DASHBOARD_UI_RUNTIME_RESTORE_SEAL.md FRESH_TASK_EVENTS_SCHEMA_DASHBOARD_REPAIR.txt

git commit -m "Seal dashboard UI runtime restore"

git push

