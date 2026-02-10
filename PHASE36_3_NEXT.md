# Phase 36.3 — Run List Observability (Planning Only)

## Purpose
Extend run-centric observability from single-run inspection to **safe listing** without introducing state, writes, or UI inference.

## Proposed Scope (planning only)
- Read-only endpoint: GET /api/runs
- Backed strictly by SQL (likely run_view)
- Deterministic ordering (explicit ORDER BY)
- Pagination via LIMIT/OFFSET or cursor (decision deferred)

## Explicit Non-Goals
- No mutations
- No aggregation beyond SQL
- No dashboards or UI coupling
- No inferred lifecycle state

## Prerequisite
- Phase 36.2 must remain unchanged and authoritative for single-run inspection.

## Status
📝 Planning stub only — no code changes in this phase yet.
