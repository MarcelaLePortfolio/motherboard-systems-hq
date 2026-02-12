# Phase 37.7 — Implementation Plan (Single Hypothesis PR)

## Hypothesis
We can safely introduce a read-only GET /api/runs endpoint backed strictly by run_view,
with deterministic ORDER BY and optional LIMIT, without altering any existing invariants.

## Contract
- Method: GET
- Path: /api/runs
- Source: run_view only
- Explicit ORDER BY (e.g., created_at DESC, run_id DESC — must be explicit)
- Optional LIMIT (default small fixed number, e.g., 50)
- No writes
- No derived JS lifecycle state
- No joins outside run_view
- No pagination cursors in this phase

## Guardrails
- run_view single-owner guard remains untouched
- No changes to worker, claim, lease, or reclaim logic
- No schema changes
- No migration files
- No mutation endpoints

## Test Surface
- Basic 200 response
- Deterministic ordering enforced in SQL
- Empty result returns []
- No side effects

## Out of Scope
- UI wiring
- Dashboard integration
- Cursor pagination
- Aggregations beyond run_view

## Protocol Reminder
- One hypothesis per PR
- PR-only to main
- Required ci/build-and-test must pass
- 3 consecutive CI failures => stop + revert to last known good
