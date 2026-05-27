# Phase 33 — Docker workers can claim delegated tasks (lane: feature/phase26-task-worker-min)

## Goal
Enable dockerized workers (workerA/workerB) to claim tasks created with status `delegated`, without breaking queued-task behavior, and keep `task_events.task_id` stable as the string task id (e.g., `t51`) rather than numeric row ids.

## Changes shipped
- **Claim SQL widened**: `server/worker/phase32_claim_one.sql` updated to claim from:
  - `WHERE status IN ('queued','delegated')`
  - uses `FOR UPDATE SKIP LOCKED` for safe multi-worker claiming
- **Worker bind-mount parity**: `docker-compose.worker.phase32.yml` now bind-mounts:
  - `./server/worker:/app/server/worker:ro` for **both** workerA and workerB
- **Stable task_id emission**: `server/worker/phase26_task_worker.mjs` emits:
  - `task_id = (row.task_id || String(row.id))`
  - ensures `task_events.task_id` stays the stable string id when present

## Verification (local)
- **SQL parity**: sha256 matched across host, workerA, workerB for `phase32_claim_one.sql`.
- **Compose config**: `docker compose -f docker-compose.worker.phase32.yml config` shows the bind-mount for both workerA and workerB.
- **End-to-end delegated run**:
  - Created 20 tasks with `status=delegated`
  - Observed clean lifecycle on SSE: `task.created → task.running → task.completed`
  - Work distribution observed across workerA and workerB actors
- **No duplicate terminal events**:
  - Query for tasks having >1 terminal event (`task.completed`/`task.failed`) returned 0 rows.
- **No numeric task_id drift**:
  - Query for `task_events.task_id ~ '^[0-9]+$'` returned 0 rows.

## Evidence snippets
- SSE log captured in `tmp/task-events-raw.*.log` shows `taskId:"t51"... actor:"docker-wA/docker-wB"` and terminal completion events.
- Terminal-event dedupe query:
  - `having count(*) filter (where kind in ('task.completed','task.failed')) > 1` returned 0 rows.

## Notes
- If stopping SSE watchers, keep the PID and redirect output to a log to avoid shell-state clobbering:
  - `curl ... >"$LOG" & SSE_PID=$!; kill -TERM "$SSE_PID"; wait "$SSE_PID"`
