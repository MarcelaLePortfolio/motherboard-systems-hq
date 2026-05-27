# PR — Phase 39.1: Action Tier Enforcement at Claim Time (SQL-first)

## What changed
- Enforced **action_tier gating at claim time** in the canonical claim SQL:
  - Only claimable when `COALESCE(action_tier,'A') = 'A'`
- Updated deterministic smokes to be robust under gating + avoid positional-param leakage:
  - Phase32 smoke now binds claim vars via `psql` vars and preflights a clean queue
  - Phase39 action_tier smoke proves Tier A claims, Tier B remains queued

## Why
Claim-time gating is the **earliest deterministic enforcement point**: it prevents non-Tier-A work from being claimed/executed regardless of downstream worker behavior or UI.

## Scope / Non-goals
- ✅ SQL-first enforcement
- ✅ Deterministic acceptance checks (smokes)
- ✅ No UI inference
- ✅ Phase-scoped changes

- ❌ No UI changes
- ❌ No new write APIs
- ❌ No schema changes beyond strictly additive scaffolding/migrations already included in this phase

## How to verify (local)
Run both smokes:
- `./scripts/phase32_null_max_attempts_claim_smoke.sh`
- `bash ./scripts/phase39_action_tier_claim_smoke.sh`

Expected:
- Phase32: NULL `max_attempts` task (Tier A) becomes `running` with `locked_by='smoke-nullmax'`
- Phase39: Tier A becomes `running`; Tier B remains `queued`

## Key invariant
If a queued task is not Tier A, it must not be claimable via the canonical claim SQL.
