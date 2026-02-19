# Phase 44 — Enforcement Promotion (EXPLICIT PROMOTION PHASE)

## Start Point
Tag: `v42.0-readonly-preserve-v41-gate-green`

## Promotion Statement (Explicit)
This phase is authorized to introduce **enforcement** (blocking) in explicitly-enumerated mutation boundaries.
All other changes remain out of scope.

## Non-Negotiables (Must Hold)
- Preserve Phase 41 invariants (no regressions; no weakening).
- Deterministic decisions only (no UI inference; no hidden state).
- Enforcement must be behind an explicit mode switch.
- Revert strategy must be one-command back to `v42.0-readonly-preserve-v41-gate-green`.

## Enforcement Mode (Kill-Switch)
Single source of truth:
- `ENFORCEMENT_MODE=off`    (no blocking)
- `ENFORCEMENT_MODE=shadow` (log decisions, no blocking)
- `ENFORCEMENT_MODE=enforce` (block disallowed mutations)

Default expectation for first rollout:
- `shadow`, then promote to `enforce` only after acceptance is green.

## First Boundary (Pick ONE for this phase)
(Choose exactly one; do not broaden.)
- [ ] Server HTTP mutation routes
- [ ] Worker state transitions
- [ ] DB-level enforcement (avoid unless unavoidable)

## Enumerated Entry Points (Must Be Exact)
List the exact files/routes that will be touched in this phase (no extras).
TBD (must be filled before implementation).

## Required Checks (Must Be Green)
- scripts/phase44_scope_gate.sh
- scripts/phase41_invariants_gate.sh
- scripts/phase41_smoke.sh

## New Acceptance (Must Be Added This Phase)
- scripts/phase44_enforcement_smoke.sh
  Proves:
  1) Allowed mutation succeeds
  2) Disallowed mutation fails deterministically in ENFORCE
  3) Disallowed mutation logs only in SHADOW
  4) OFF mode does not block
