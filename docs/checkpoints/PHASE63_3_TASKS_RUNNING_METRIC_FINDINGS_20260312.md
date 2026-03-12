# PHASE 63.3 TASKS RUNNING METRIC FINDINGS
Date: 2026-03-12

## Summary

Initial Phase 63.3 Tasks Running metric audit findings captured from the verified Phase 63.2 golden baseline.

## Current Provenance Corridor

Primary browser-side Tasks Running metric corridor is:

- `public/js/agent-status-row.js`
- `PHASE63_SHARED_TASK_EVENTS_METRICS` block

This corridor owns:

- `metric-tasks`
- running task ID tracking
- add/remove semantics for active task membership
- idle/null display behavior for the task count metric

## Current Inclusion Semantics

Observed browser-side logic indicates:

- running membership is driven by `runningTaskIds`
- running count is rendered as `runningTaskIds.size`
- running task IDs are added only from running-task event types
- running task IDs are removed only from terminal event types

## Idle / Null Semantics

Current idle behavior is count-based rather than placeholder-based:

- `metric-tasks = 0` when no running task IDs exist

No `—` placeholder is used for the running-tasks metric.

## Audit Direction

Next narrow check:

- verify exact running event types that seed membership
- verify exact terminal event types that clear membership
- verify whether the current `0` idle semantics are acceptable from this baseline
- verify whether duplicate running events remain harmless because membership is set-based

## Rule

Audit only before implementation.

No layout mutation.
No ID changes.
No structural wrappers.
No producer mutation.
