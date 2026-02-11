# Phase 37.6 — Hypothesis

## Hypothesis
Prevent run_view drift by enforcing a single canonical owner for run_view DB queries.

## Canonical Owner
- server/routes/phase36_run_view.mjs

## Gate
- scripts/phase37_6_run_view_single_owner_check.sh (runs via run_tests.sh / CI)

## Non-goals
- No schema changes
- No worker changes
- No behavior changes (runtime)
