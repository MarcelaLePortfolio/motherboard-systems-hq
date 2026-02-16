# Phase 42 — Branch Protection API 404 (gh api)

## What happened
A `gh api` call to set `required_approving_review_count=0` returned HTTP 404.

Most common cause:
- gh token does not have admin permission on the repo.
- GitHub returns 404 instead of 403 for protected endpoints.

## Goal
Keep PR-only main with required checks,
but remove the “1 approving review required” gate for a solo repo.

## Resolution
Either:
- Refresh gh auth with proper scopes and retry the API call, OR
- Update branch protection in GitHub UI manually.
