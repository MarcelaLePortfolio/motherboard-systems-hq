# Phase 42 — Next Steps (Ruleset + Review Gate Fix)

## Current state (confirmed)
- PR merges are blocked by: **“At least 1 approving review is required”**.
- GitHub Settings → Branches shows: **“Classic branch protections have not been configured”**
  which means your enforcement is coming from **Rulesets** (or no classic protection exists).
- Classic Branch Protection API endpoints can return **404 Branch not protected** when Rulesets are used.

## What to do in GitHub UI (recommended)
Open:
- Repo Settings → Branches

Then choose ONE approach:

### Option A — Ruleset (recommended if you want modern enforcement)
1) Click **Add branch ruleset**
2) Name it: `main-pr-only`
3) Target branches: include `main`
4) Turn on:
   - **Require a pull request before merging**
   - **Require status checks to pass**
     - add required check: `ci/build-and-test`
5) Turn OFF (for solo repo):
   - **Require approvals** (set to 0 / disable approvals requirement)
6) Save ruleset

### Option B — Classic Branch Protection (simple + compatible with gh API)
1) Click **Add classic branch protection rule**
2) Branch name pattern: `main`
3) Turn on:
   - **Require a pull request before merging**
   - **Require status checks to pass before merging**
     - require: `ci/build-and-test`
4) Set:
   - **Required approving reviews: 0** (solo repo)
5) Save rule

## After you change Settings
- Re-open PR #27 and it should become mergeable (no approval required, checks still required).
