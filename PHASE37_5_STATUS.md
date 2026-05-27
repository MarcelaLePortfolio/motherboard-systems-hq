# Phase 37.5 — Status (Golden)

## Result
✅ Merged to main via PR #2  
✅ Golden tag: v37.5-run-view-terminal-kind-normalization-golden

## Scope
- Projection-only: run_view terminal_event kind normalization
- Acceptance normalization aligned to the same kind-set
- CI fix: repo-root run_tests.sh wrapper for GitHub Actions
- No schema changes
- No worker changes

## Verification
PHASE37_ACCEPTANCE_CHECKS.sql executed against local postgres container and returned 0 rows for all failure checks (run_view rowcount reported 15).
