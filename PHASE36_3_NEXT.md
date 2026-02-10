# Phase 36.3 — Run List Observability (PLANNING ONLY)

## Goal
Define the read-only observability surface for listing runs, without implementing it yet.

## Non-Goals
- No writes or mutations
- No worker changes
- No pagination logic implementation
- No UI changes beyond planning notes

## Proposed API Shape (Tentative)
- GET /api/runs
- Backed strictly by SQL (view or deterministic SELECT)
- Read-only, DB is source of truth

## Data Source (Tentative)
- run_view or a new runs_list_view
- One row per run_id
- No derived or UI-computed state

## Open Questions
- Required filters (status? time range?)
- Default ordering (created_at vs updated_at)
- Upper bounds / safety limits
- Whether a dedicated SQL view is warranted

## Invariants
- Deterministic results
- Idempotent reads
- No side effects
- SQL defines truth

## Exit Criteria (Planning)
- API contract agreed
- SQL source identified
- Invariants locked
- Explicit non-goals documented
