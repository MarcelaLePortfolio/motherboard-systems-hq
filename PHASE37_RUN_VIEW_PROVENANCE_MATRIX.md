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
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

## last_event_ts
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

## last_event_kind
- Source(s):
- Rule (SQL):
- Latest semantics (by canonical ordering):
- Nullability semantics:
- Stability requirement:
- Notes:

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

