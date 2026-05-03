# Phase 37.7 — Run List (Read-Only, Deterministic)

## Purpose
Extend run-centric observability from single-run inspection to safe, read-only listing.

## In Scope
- GET /api/runs
- Backed strictly by run_view
- Deterministic ORDER BY (explicit)
- No writes, no derived state, no JS aggregation

## Invariants
- run_view remains single-owner enforced (guard unchanged)
- No mutation paths introduced
- SQL is the sole source of truth

## Out of Scope
- Dashboards
- Lifecycle inference
- Pagination strategy beyond minimal deterministic LIMIT

## Protocols
- PR-only to main
- Required ci/build-and-test must pass
- One hypothesis per PR
- 3 consecutive CI failures => stop + revert to last known good
