# Phase 39.1 — Action Tier Enforcement at Claim Time (SQL-first)

## Goal
Enforce `action_tier` at **claim time** in the worker claim SQL (SQL-first), so that only Tier-A work can be claimed/executed.

## In Scope
- Add a deterministic, SQL-level predicate to the claim query:
  - allow claim only when `COALESCE(action_tier,'A') = 'A'`
- Deterministic smoke/acceptance checks:
  - Tier A task can be claimed
  - Tier B task cannot be claimed (remains queued)
- No UI inference
- Phase-scoped commits

## Out of Scope
- Any UI changes
- Any new write APIs
- Any schema changes (unless strictly required; avoid)

## Invariant
If a queued task is not Tier A, it must not be claimable via the canonical claim SQL.
