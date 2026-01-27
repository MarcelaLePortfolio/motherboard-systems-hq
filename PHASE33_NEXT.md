# Phase 33 — Next focus (post-Drizzle stabilization)

## Stable base (do not regress)
- Phase 32 Drizzle lanes are DONE and tracked.
- SQLite + Postgres migrations are clean and verified.

## Recommended next step
Resume **worker reliability hardening** (Phase 26/27 loop + Phase 28+ routing):
- Validate claim/lock semantics under concurrency.
- Validate retry/backoff behavior and observability (attempts/next_run_at/last_error).
- Validate failure routing consistency (tasks.status + task_events kinds).

## Entry checklist (guardrails)
- Keep Drizzle untouched unless a schema change is explicitly required.
- Any new schema change must land in exactly one lane:
  - SQLite-safe → `drizzle/` (+ `drizzle/meta/_journal.json`)
  - Postgres-only → `drizzle_pg/` (+ `drizzle_pg/meta/_journal.json` and `drizzle.__drizzle_migrations`)

## First action (suggested)
- Run a focused local concurrency smoke:
  - create N tasks quickly
  - run 1 worker (then 2 workers)
  - confirm: exactly-once claim, no double-complete, clean SSE stream
