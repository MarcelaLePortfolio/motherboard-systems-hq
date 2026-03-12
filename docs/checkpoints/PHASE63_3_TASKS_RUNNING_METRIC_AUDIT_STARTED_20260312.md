# PHASE 63.3 TASKS RUNNING METRIC AUDIT STARTED
Date: 2026-03-12

## Summary

Continue Phase 63.3 from the verified Phase 63.2 golden baseline with a narrow audit of the Tasks Running metric provenance and idle/null semantics.

## Verified Prior State

- Phase 63.2 remains closed and protected
- Phase 63.3 baseline verified
- heartbeat audit complete
- success metric formula audit complete
- latency sampling audit complete
- no producer mutation required so far

## Audit Focus

Trace and verify the current source of truth for:

- `metric-tasks`
- running task inclusion semantics
- task add/remove logic
- idle/null display behavior before task activity exists
- whether the metric is driven only by currently active task IDs

## Rule

Audit only before implementation.

No layout mutation.
No ID changes.
No structural wrappers.
No producer mutation.

## Next

Use bounded inspection only across:

- `public/js/agent-status-row.js`
- task-event SSE corridor
- task event emitters / routes
- Phase 63 verifier scripts
