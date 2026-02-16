# Phase 43 — Complete (Governance Baseline + Self-Audit)

## Result
Phase 43 is sealed on `main` with:
- PR-only enforced for `main`
- Required status check enforced: `ci/build-and-test`
- No approvals required

## Proof
Run:
- `./scripts/phase43_governance_audit.sh`

Expected PASS summary:
- governance baseline is ACTIVE for main (PR-only + required checks + no approvals)

## Notes
- Classic branch protection endpoint may be unreachable (rulesets-only enforcement).
- Force-push/delete settings may be non-provable via API in rulesets-only mode; audit flags this as WARN only.
