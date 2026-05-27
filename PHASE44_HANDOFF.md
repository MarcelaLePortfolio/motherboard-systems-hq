# Phase 44 — Completion Handoff (Runtime Integrity Guard)

## What shipped
- Runtime integrity guard enforcing **action-tier invariants** (fail-fast)
  - `server/guards/phase44_runtime_integrity_guard.mjs`
  - `assertActionTierInvariant({ actionTier, actionId })`
- Structural authorization allowlist (code-owned)
  - `server/guards/phase44_structural_auth_allowlist.json`
- Runtime wiring (current execution path)
  - `server/api/tasks-mutations/delegate-taskspec.mjs`
- CI enforcement (required check now satisfied)
  - `.github/workflows/ci-build-and-test.yml`
  - plus existing status-context workflow `ci_build_and_test_status_context.yml`
- Smoke tests
  - `scripts/phase44_action_tier_guard_smoke.sh`
- Post-merge verification helper
  - `scripts/phase44_postmerge_verify.sh`

## Invariants
- Tier A always allowed
- Tier B/C denied unless explicitly allowlisted
- No schema changes
- CI runs guard smoke (via `scripts/test.sh` hook if present)

## How to authorize Tier B/C (structural)
Edit:
- `server/guards/phase44_structural_auth_allowlist.json`

Add the action identifier under:
- `tierB` or `tierC`

## Quick verify
- `./scripts/phase44_postmerge_verify.sh`

## Merge records
- PR #35 merged → guard + wiring + CI requirement satisfied
- PR #36 merged → post-merge verification script
