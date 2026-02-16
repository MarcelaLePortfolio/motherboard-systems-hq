# Phase 42 — PR-Only Main Enforcement (Revert)

## Intent
Undo a direct-to-main hygiene commit by reverting it **via a PR** so `main` stays PR-only and required checks remain enforceable.

## What this PR does
- Applies a `git revert` of the identified direct-to-main hygiene commit (no history rewrite).
- Keeps the rollback reviewable and gated behind CI + required checks.

## Notes
- If branch protection / required checks were temporarily bypassed for the original commit, this PR restores the PR-only hygiene path.
