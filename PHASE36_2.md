# Phase 36.2 — Run-Centric Observability

## Goal
Provide a read-only, canonical view of a run’s current state by consuming run_view.

## In Scope
- Read-only API: GET /api/runs/:run_id
- Query backed strictly by run_view
- No side effects, no writes

## Out of Scope
- Reclaim / lease mutation
- Worker logic
- UI dashboards beyond inspection

## Invariants
- One row per run_id
- Deterministic fields (no derived JS state)
- SQL is the source of truth
