PHASE 62B — TASKS COMPLETED EXECUTION PROTOCOL
Date: 2026-03-16

────────────────────────────────

OBJECTIVE

Harden Tasks Completed derivation using the existing task-events-derived telemetry surface.

Primary implementation surface:

public/js/phase22_task_delegation_live_bindings.js

This is a telemetry-only hardening step.

────────────────────────────────

IMPLEMENTATION BOUNDARY

Allowed:

• refine completed-count derivation inside the existing phase22 bindings surface
• ensure completed count increments only from terminal success conditions
• add bounded local verification artifact
• preserve current Running Tasks derivation unchanged unless required for consistency

Forbidden:

• task-events SSE transport edits
• server route edits
• layout HTML edits
• dashboard structural edits
• reducer redesign
• multi-file telemetry refactor
• authority expansion
• automation work

────────────────────────────────

DETERMINISTIC RULE

Tasks Completed must count terminal success only.

Accepted success signals:

• task.completed
• status done
• status complete
• status completed

Rejected for completed count:

• task.failed
• task.cancelled
• task.canceled
• queued
• started
• running
• unknown events

Duplicate terminal success for same task must not double count.

Terminal failure/cancel for same task must never increment completed count.

If terminal success arrives before non-terminal events:
completed count must remain valid and task must never later be double-counted.

────────────────────────────────

STATE MODEL

Use bounded task identity tracking.

Preferred approach:

completedTaskIds = Set()

Rules:

On terminal success for task_id:
  if task_id not already in completedTaskIds
    add task_id
    completedCount += 1

On duplicate terminal success:
  no change

On failed/cancelled terminal:
  do not increment completedCount

On non-terminal events:
  no increment

This must remain deterministic under replay.

────────────────────────────────

REQUIRED VERIFICATION CASES

• created -> started -> completed
• started -> completed
• completed -> started
• duplicate completed
• created -> failed
• created -> cancelled
• failed -> completed (define and verify intended behavior explicitly)
• unknown event ignored
• multi-task overlap with mixed success/failure

Success requirement:

Completed count advances only on first valid terminal success per task.

────────────────────────────────

COMMIT RULE

One file only for first implementation pass.
One hypothesis only.
One bounded verification pass after implementation.

────────────────────────────────

SUCCESS CONDITION

Tasks Completed derivation is hardened deterministically inside the existing telemetry surface with no layout, transport, or authority change.

