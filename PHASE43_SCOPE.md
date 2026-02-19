# Phase 43 — Read-Only Continuation (Preserve Phase 41 Invariants)

## Start Point
Tag: `v42.0-readonly-preserve-v41-gate-green`

## Gate (Must Hold)
- Preserve Phase 41 invariants (no regressions; no weakening).
- Remain strictly read-only unless an explicit “promotion phase” authorizes writes.
- No schema changes unless explicitly promoted (and then only additive + contract-safe).

## Allowed (Read-Only)
- Read-only endpoints / projections / views
- Read-only validation and correctness checks
- Deterministic reporting / observability
- Documentation + acceptance checks

## Not Allowed (Unless Explicitly Promoted)
- New write routes (POST/PUT/PATCH/DELETE)
- Worker behavior changes that mutate task state
- Lease/reclaim/heartbeat mutation changes
- Schema migrations

## Required Checks (Must Be Green)
- scripts/phase43_scope_gate.sh
- scripts/phase42_readonly_guard.sh (still baseline diff guard vs v41; keep it green)
- scripts/phase41_invariants_gate.sh
- scripts/phase41_smoke.sh
