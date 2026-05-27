# Phase 42 — Postmortem (PR-only main + Rulesets)

## Final outcome
- `main` is **PR-only** and rejects direct pushes (GH013 repository rules violation).
- Required status check enforcement is active:
  - `ci/build-and-test`
- Solo-repo review deadlock resolved:
  - Required approvals set to **0** in the active ruleset.
- Duplicate ruleset conflict resolved by disabling the older ruleset:
  - Kept: `main-pr-only`
  - Disabled: `Main Branch Protection`
- Proof run completed via PR #28.

## Root causes encountered
1) **Rulesets vs Classic branch protection mismatch**
   - GitHub UI indicated classic branch protections were not configured.
   - Classic branch protection REST endpoints returned 404.

2) **Two rulesets targeting `main`**
   - GitHub enforces the strictest combination across applicable rulesets.
   - One ruleset still required 1 approval, causing `REVIEW_REQUIRED` on PRs.

3) **Zsh quoting & gh UX friction**
   - `-f required_status_checks.contexts[]=...` needs quoting in zsh.
   - gh device login uses an 8-char device code (`XXXX-XXXX`), not authenticator OTP.

## Artifacts produced (docs)
- PHASE42_PR_ONLY_REVERT.md
- PHASE42_BRANCH_PROTECTION_REVIEW_GATE.md
- PHASE42_GH_DEVICE_AUTH_NOTES.md
- PHASE42_NEXT_STEPS_RULESET_FIX.md
- PHASE42_RULESET_REVIEW_GATE_FIX.md
- PHASE42_RULESET_DUPLICATE_RULESETS_FIX.md

## Recommended steady-state configuration (solo repo)
Ruleset: `main-pr-only` (Active), targeting default branch (`main`)
- Require a pull request before merging ✅
- Required approvals = 0 ✅
- Require status checks to pass ✅ (`ci/build-and-test`)
- Block force pushes ✅
- (Optional) Restrict deletions ✅

## Next time (faster path)
1) First check Rulesets list for duplicates targeting `main`.
2) Keep one ruleset; disable the rest.
3) Only then validate PR merge state via:
   `gh pr view <n> -R <owner/repo> --json mergeStateStatus,reviewDecision`
