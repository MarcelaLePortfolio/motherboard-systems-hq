# Phase 44 — Runtime Integrity Guard (Action Tier)

## Goal
Design + implement a **runtime integrity guard** that asserts **action-tier invariants at execution time**:
- **Tier A** actions: allowed
- **Tier B / Tier C** actions: **fail-fast** unless explicitly **structurally authorized** (code-owned allowlist)

## Hard Constraints
- **No schema changes**
- Enforced via **CI**
- Fail-fast behavior must be deterministic and reviewable

## Implementation
### Guard module
- `server/guards/phase44_runtime_integrity_guard.mjs`
  - `assertActionTierInvariant({ actionTier, actionId })`
  - Tier B/C require allowlist membership; otherwise throws `E_ACTION_TIER_GUARD`

### Structural authorization (allowlist)
- `server/guards/phase44_structural_auth_allowlist.json`
  - `tierB: [ ... ]`
  - `tierC: [ ... ]`

### Runtime wiring
- Guard invoked at runtime in the execution path (current wiring):
  - `server/api/tasks-mutations/delegate-taskspec.mjs`

## CI Enforcement
- Smoke script:
  - `scripts/phase44_action_tier_guard_smoke.sh`
- Hooked into CI entrypoint (if present):
  - `scripts/test.sh` (appends Phase 44 smoke)

## Acceptance
- Tier A always passes
- Tier B/C without allowlist entry reliably fails-fast at runtime
- CI runs the smoke script and fails if the guard regresses
- No DB or schema changes introduced

## PR
- PR #35 (feature/phase44-runtime-integrity-guard → main)
