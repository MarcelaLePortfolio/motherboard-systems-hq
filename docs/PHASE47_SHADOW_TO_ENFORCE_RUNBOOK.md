# Phase 47 — Shadow → Enforce Promotion Runbook

This runbook promotes decision enforcement after Phase 47.2 is golden.

## Preconditions (must be true)
- Tag `v47.2-decision-correctness-golden` exists and smoke is green:
  - `./scripts/phase47_smoke.sh`
- Shadow audit checks remain green (no regressions in task_events/run_view invariants).
- Deployment is using the exact merge commit on main (no local-only commits).

## Promotion principle
Change **one thing**: flip enforcement on (keep everything else identical).

## Where to flip
Promotion is done via **env flags** (deployment configuration), not by changing logic:
- Set enforce flag **ON**
- Set shadow flag **OFF** (or leave ON if your policy supports dual-write; prefer OFF to avoid ambiguity)

Common patterns (use whichever exists in this repo’s deployment config):
- `POLICY_ENFORCE_ENABLED=1`
- `POLICY_SHADOW_ENABLED=0`

If your deployment uses different names, map them in the deployment config PR only.

## Promotion steps
1) Open a PR that updates deployment config/environment **only**.
2) Merge with required checks.
3) Deploy.
4) Verify:
   - `./scripts/phase47_smoke.sh`
   - Dashboard reads still work
   - Workers still claim/lease/reclaim without invariant violations

## Rollback protocol (fast)
If anything breaks after enforce:
1) Flip enforce flag **OFF** and shadow flag **ON** (config-only rollback).
2) Redeploy.
3) If code regression is suspected anyway:
   - Revert the promotion PR via PR revert (single revert commit), merge with checks.
4) Do not move golden tags.

## Audit note
- `v47.0-decision-correctness-golden` is historical.
- `v47.2-decision-correctness-golden` is the current decision-correctness proof.
