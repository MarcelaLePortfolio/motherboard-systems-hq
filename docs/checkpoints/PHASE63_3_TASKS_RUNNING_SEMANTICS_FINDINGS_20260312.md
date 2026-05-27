# PHASE 63.3 TASKS RUNNING SEMANTICS FINDINGS
Date: 2026-03-12

## Summary

Continue Phase 63.3 with a narrow finding pass on exact Tasks Running membership semantics from the verified Phase 63.2 golden baseline.

## Exact Running Membership Seed Set

Current running-task event types are:

- `created`
- `queued`
- `leased`
- `started`
- `running`
- `in_progress`
- `delegated`
- `retrying`

## Exact Running Membership Clear Set

Current terminal event types that clear running membership are:

Success:
- `completed`
- `complete`
- `done`
- `success`

Failure:
- `failed`
- `error`
- `cancelled`
- `canceled`
- `timed_out`
- `timeout`
- `terminated`
- `aborted`

## Metric Semantics

Current Tasks Running metric is:

- driven only by `runningTaskIds`
- rendered as `runningTaskIds.size`
- idempotent for duplicate running events because membership is set-based
- cleared only by terminal outcomes for the same task ID

## Idle / Null Semantics

Current baseline semantics remain:

- `metric-tasks = 0` when no running task IDs exist

This is count-based idle behavior rather than placeholder behavior.

## Assessment

Current Tasks Running semantics are internally coherent for this audit pass:

- inclusion set is explicit
- clear set is explicit
- duplicate running events remain harmless
- idle state is deterministic and acceptable from this baseline

## Next

Proceed to the next narrow Phase 63.3 telemetry audit target:

- telemetry null-state consistency across all four metric tiles

## Safety

No layout mutation.
No ID changes.
No structural wrappers.
No producer mutation.
