# Phase 36.6 — Run List Filters (Read-Only)

## Goal
Add deterministic, read-only filtering for the Runs list, backed strictly by run_view.

## In Scope
- GET /api/runs: support filters via query params:
  - limit (capped server-side)
  - task_status (repeatable)
  - is_terminal (true|false)
  - actor (exact)
  - since_ts (ms epoch; last_event_ts >= since_ts)
- Dashboard UI: filter controls that map 1:1 to query params (no derived state)

## Out of Scope
- Any writes/mutations
- Worker/lease/reclaim logic
- UI inference / computed status

## Invariants
- run_view remains the canonical source of truth
- Parameterized SQL only
- Deterministic ordering preserved
