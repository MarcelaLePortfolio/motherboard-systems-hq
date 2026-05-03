# Phase 42 — Fix: Duplicate Rulesets Still Forcing “Review required”

## What you reported
- You see **two separate rulesets** that both target `main`:
  - “Main Branch Protection”
  - “main-pr-only”

If two rulesets both apply to `main`, GitHub enforces the **strictest** combined set of requirements. That’s why you still see **Review required** even after setting approvals to 0 in one ruleset.

## Goal
Keep:
- PR-only main
- Required status check: `ci/build-and-test`

Remove:
- Any requirement for approvals/reviews (solo repo)

## Manual UI steps (fast + definitive)
1) Go to: Settings → Rules → Rulesets
2) Open **“Main Branch Protection”** first.
3) In its “Pull request” rule (or similar section), set:
   - Required approvals = **0** OR disable approvals entirely
   - Disable Code Owners review requirements
   - Disable “approval of most recent push”
   - Disable “review from specific teams”
4) Save.

5) Open **“main-pr-only”** and confirm it matches the intended minimal set:
   - Require a pull request before merging ✅
   - Require status checks to pass ✅ (`ci/build-and-test`)
   - Block force pushes ✅
   - Required approvals = **0** ✅
   - No code owners / teams / last-push approval ✅
6) Save.

## Optional: Preferred simplification (recommended)
To avoid this happening again, keep **only one** ruleset targeting `main`.

Option A (recommended): Keep **main-pr-only**, remove or disable **Main Branch Protection**
- In “Main Branch Protection”, either:
  - Disable the ruleset (Enforcement status → Disabled), OR
  - Delete it, OR
  - Change its target so it does NOT include `main`

## Terminal validation (after saving ruleset changes)
Run:
- `gh pr view 28 -R MarcelaLePortfolio/motherboard-systems-hq --json mergeStateStatus,reviewDecision --jq '"merge=\(.mergeStateStatus) review=\(.reviewDecision)"'`

Expected:
- reviewDecision should NOT be REVIEW_REQUIRED
- mergeStateStatus should become CLEAN / MERGEABLE (once checks pass)

Then merge:
- `gh pr merge 28 -R MarcelaLePortfolio/motherboard-systems-hq --squash --delete-branch`
