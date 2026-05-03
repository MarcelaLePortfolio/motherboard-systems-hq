# Phase 42 — Fix “Review required” gate (Ruleset vs Classic)

## Symptom
PR merge blocked by:
- “At least 1 approving review is required by reviewers with write access.”

## Why this is happening
This requirement is coming from a repo **Ruleset** (not classic branch protection).

## Goal
Keep:
- PR-only main
- Required checks (ci/build-and-test)
Remove:
- Required approvals (solo repo)

## Terminal plan
1) List rulesets: `gh api repos/$OWNER/$REPO/rulesets`
2) Identify ruleset targeting `main` with a `pull_request` rule
3) Patch that rule to set `required_approving_review_count` to 0
4) Merge PRs normally (no bypass)

## UI fallback
Settings → Rules → Rulesets → (ruleset for main)
- Pull request: set approvals required to 0 (or disable approvals)
- Keep required status checks
