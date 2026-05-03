Phase 29 — DB doctor + non-destructive migration + worker compatibility (current state)

Branch:
- feature/phase28-failure-routing-smoke

Checkpoint tags:
- v29.0-phase29-db-migrate-smoke-ok (doctor + migration + phase29 smoke)
- v29.1-phase29-worker-compat-ok (worker writes payload_jsonb when available; prefers tasks.payload over meta; memoized schema probe)

What we added:
- server/worker/phase29_db_doctor.sh
  - Prints a pipe-delimited snapshot of schema “flavor”:
    - tasks: payload/meta/attempt/attempts/available_at/next_run_at
    - task_events: payload presence + payload type + run_id + actor
- server/worker/phase29_db_migrate_to_phase27.sql
  - Non-destructive “toward-canonical” migration:
    - tasks: add payload jsonb + attempts int + next_run_at timestamptz (if missing)
    - backfill payload from meta (best-effort)
    - backfill attempts from attempt (best-effort)
    - backfill next_run_at from available_at (best-effort)
    - task_events: add payload_jsonb jsonb (if missing) without changing legacy payload text
    - best-effort parse legacy payload text -> payload_jsonb
- scripts/phase29_smoke_migrate_then_smoke.sh
  - Runs doctor BEFORE/AFTER migration, then runs deterministic Phase28 smoke.

Worker compatibility:
- server/worker/phase26_task_worker.mjs
  - Writes payload_jsonb when present; always writes payload text for legacy DBs.
  - taskPayload prefers tasks.payload, falls back to tasks.meta.
  - Memoizes schema probe to avoid per-event information_schema hits.

How to verify (local):
- POSTGRES_URL=... ./scripts/phase29_smoke_migrate_then_smoke.sh
