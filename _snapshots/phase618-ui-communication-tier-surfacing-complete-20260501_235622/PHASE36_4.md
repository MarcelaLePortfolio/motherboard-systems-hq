# Phase 36.4 — Run List Observability (IMPLEMENTATION)

## Goal
Ship read-only run list endpoint:
- GET /api/runs
- Backed strictly by SQL `run_view` (or `runs_list_view` if created)
- No writes, no side effects
- Deterministic ordering and filters

## In Scope
- API: GET /api/runs
- Query is DB truth (SQL is canonical)
- Ordering:
  - last_event_ts DESC NULLS LAST
  - last_event_id DESC NULLS LAST
  - run_id DESC
- Inputs:
  - limit (default 50, max 200)
  - task_status (optional, exact match)
  - is_terminal (optional, exact match)
  - since_ts (optional, epoch-ms; last_event_ts >= since_ts)
- Response:
  - ok + items[] + next_cursor (null for now)

## Out of Scope
- Pagination implementation (cursor behavior)
- Writes/mutations
- Worker logic
- UI work beyond inspection wiring

## Invariants
- Read-only
- DB is source of truth
- Deterministic/idempotent
- No UI-derived or JS-derived state beyond serialization
