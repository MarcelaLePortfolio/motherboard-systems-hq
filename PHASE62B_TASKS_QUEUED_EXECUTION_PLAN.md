PHASE 62B — TASKS QUEUED
DETERMINISTIC EXECUTION PLAN

OBJECTIVE

Hydrate Tasks Queued metric using existing telemetry surfaces only.

CONSTRAINTS

Read-only operation.
No reducer changes.
No SSE changes.
No layout changes.
No authority interaction.

IMPLEMENTATION STRATEGY

Definition:

Tasks Queued =
tasks where status = 'queued'
OR
tasks where run_state = 'pending'
(verify actual column locally before wiring)

QUERY SHAPE (REFERENCE ONLY)

SELECT COUNT(*)
FROM tasks
WHERE status = 'queued';

(Adjust column name if schema differs)

EXECUTION STEPS

1 Identify exact queued definition from tasks table.
2 Add deterministic count query alongside existing running/completed/failed queries.
3 Wire result into existing telemetry hydration object.
4 Do NOT create new transport paths.
5 Do NOT modify reducer shape.
6 Verify dashboard renders without mutation.

LOCAL VERIFICATION CHECKLIST

Confirm:

Metric appears
Counts match DB reality
Running metric unchanged
Completed metric unchanged
Failed metric unchanged
No console errors
No layout shifts

ROLLBACK PLAN

If ANY regression:

git restore .
git clean -fd

Restore last golden tag if required.

COMPLETION CRITERIA

Tasks Queued metric visible.
Zero behavioral drift.
Corridor integrity preserved.

END PLAN
