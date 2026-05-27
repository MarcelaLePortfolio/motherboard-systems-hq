# Phase 42 — Branch Protection Review Gate (Solo Repo)

## Symptom
PR merge blocked with:
- "Review required — At least 1 approving review is required by reviewers with write access."

## Root Cause
Branch protection is configured to require ≥1 approval, but the repo effectively has only one write-access reviewer.

## Fix (keep PR-only + required checks; remove approval gate)
Set required approving review count to 0 for `main` while leaving required status checks intact.

## Follow-up (optional)
If/when a second write-access collaborator exists, re-enable required approvals (e.g., 1) to restore review gating.
