# Phase 37 — run_view Provenance Matrix (Planning Only)

## How to use
Fill one section per `run_view` column. Keep everything SQL-traceable.

Canonical ordering key for “latest” semantics (unless column specifies otherwise):
- `task_events.ts` ASC
- tie-breaker: `task_events.id` ASC

## References
- `PHASE37_RUN_VIEW_DEFINITION.sql` (authoritative view definition as captured from Postgres)
- `PHASE37_RUN_PROJECTION_CONTRACT.md` (contract + inventory)

---

## run_id
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

## task_id
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

## actor
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

## lease_expires_at
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

## lease_fresh
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

## lease_ttl_ms
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

## last_heartbeat_ts
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

## heartbeat_age_ms
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

## last_event_id
- Source(s):
  - `public.task_events` (filtered to `run_id IS NOT NULL`)
- Rule (SQL):
  - Canonical (contract): for each `run_id`, select the final row by canonical ordering, then project `id`.
    - `SELECT DISTINCT ON (run_id) run_id, id AS last_event_id FROM task_events WHERE run_id IS NOT NULL ORDER BY run_id, ts DESC, id DESC`
- Latest semantics (by canonical ordering):
  - “Last event” per `run_id` is the row with MAX `(ts, id)` (i.e., the final event in `ORDER BY ts ASC, id ASC`).
- Nullability semantics:
  - `NULL` iff there are no `task_events` rows with that `run_id`.
- Stability requirement:
  - Deterministic for a fixed underlying `task_events` set; new events may advance the value.
- Notes:
  - View authority (`PHASE37_RUN_VIEW_DEFINITION.sql`):
    - CTE `last_event` computes `last_event_id` via `SELECT DISTINCT ON (task_id, run_id) ... ORDER BY id DESC`.
    - Outer query returns one row per `run_id` via `SELECT DISTINCT ON (run_id)` and orders by `last_event_ts DESC NULLS LAST, last_event_id DESC NULLS LAST`.
  - Validation lens (`PHASE37_ACCEPTANCE_CHECKS.sql` §2a) asserts equivalence to canonical MAX `(ts,id)` per `run_id` (no mismatches allowed).

## last_event_ts
- Source(s):
  - `public.task_events` (filtered to `run_id IS NOT NULL`)
- Rule (SQL):
  - Canonical (contract): for each `run_id`, select the final row by canonical ordering, then project `ts`.
    - `SELECT DISTINCT ON (run_id) run_id, ts AS last_event_ts FROM task_events WHERE run_id IS NOT NULL ORDER BY run_id, ts DESC, id DESC`
- Latest semantics (by canonical ordering):
  - `last_event_ts` is the `ts` of the row with MAX `(ts, id)` for the `run_id` (final event in `ORDER BY ts ASC, id ASC`).
- Nullability semantics:
  - `NULL` iff there are no `task_events` rows with that `run_id`.
- Stability requirement:
  - Deterministic for a fixed underlying `task_events` set; non-decreasing across new events for a run (by definition).
- Notes:
  - View authority (`PHASE37_RUN_VIEW_DEFINITION.sql`):
    - CTE `last_event` exposes `te_1.ts AS last_event_ts` for the chosen “last event” row.
    - Outer ordering uses `last_event_ts DESC NULLS LAST` to pick the most recent event per run.
  - Validation lens (`PHASE37_ACCEPTANCE_CHECKS.sql` §2a) compares `run_view.last_event_ts` to canonical max `(ts,id)` per `run_id`.

## last_event_kind
- Source(s):
  - `public.task_events` (filtered to `run_id IS NOT NULL`)
- Rule (SQL):
  - Canonical (contract): for each `run_id`, select the final row by canonical ordering, then project `kind`.
    - `SELECT DISTINCT ON (run_id) run_id, kind AS last_event_kind FROM task_events WHERE run_id IS NOT NULL ORDER BY run_id, ts DESC, id DESC`
- Latest semantics (by canonical ordering):
  - `last_event_kind` is the `kind` of the row with MAX `(ts, id)` for the `run_id` (final event in `ORDER BY ts ASC, id ASC`).
- Nullability semantics:
  - `NULL` iff there are no `task_events` rows with that `run_id`.
- Stability requirement:
  - Deterministic for a fixed underlying `task_events` set; updates only when a newer event exists for that run.
- Notes:
  - View authority (`PHASE37_RUN_VIEW_DEFINITION.sql`):
    - CTE `last_event` exposes `te_1.kind AS last_event_kind` for the chosen “last event” row.
  - Validation lens (`PHASE37_ACCEPTANCE_CHECKS.sql` §2a) compares `run_view.last_event_kind` to canonical max `(ts,id)` per `run_id`.

## task_status
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

## is_terminal
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

## terminal_event_kind
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

## terminal_event_ts
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

## terminal_event_id
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:
