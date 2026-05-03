# Phase 42 — Read-Only Continuation (Preserve Phase 41 Invariants)

## Start Point
Tag: `v41.0-decision-correctness-gate-green`

## Non-Negotiables (Gate)
Phase 42 MUST:
- Preserve all Phase 41 invariants (no regressions; no weakening).
- Remain strictly read-only unless an explicit, later “promotion” phase authorizes writes.
- Avoid any schema changes unless explicitly promoted (and then only via additive, contract-safe steps).

## Scope (Default: Read-Only Only)
Allowed:
- Read-only endpoints / projections / views
- Read-only validation and correctness checks
- Observability (read-only) and deterministic reporting
- Documentation + acceptance checks

Not allowed (unless explicitly promoted):
- Any new write endpoints (POST/PUT/PATCH/DELETE)
- Any worker behavior changes that mutate task state
- Any lease/reclaim/heartbeat mutation logic changes
- Any schema migrations

## Acceptance (What “Green” Means)
Phase 42 is green ONLY if:
- Phase 41 acceptance checks remain green.
- No new writes are introduced.
- Read-only additions are projection-safe and do not change runtime semantics.

## Promotion Protocol (If/When Needed)
To introduce writes later:
- Create a dedicated promotion phase (explicitly labeled) that:
  - Enumerates new write paths and invariants impacted
  - Adds focused acceptance checks for write safety
  - Defines a revert strategy back to the Phase 41 golden tag
