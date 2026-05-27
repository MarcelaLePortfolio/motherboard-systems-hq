PHASE 62B — TASKS FAILED EXECUTION PROTOCOL
Date: 2026-03-16

────────────────────────────────

OBJECTIVE

Harden Tasks Failed derivation using the existing task-events-derived telemetry surface.

Primary implementation surface:

public/js/phase22_task_delegation_live_bindings.js

This is a telemetry-only hardening step.

────────────────────────────────

IMPLEMENTATION BOUNDARY

Allowed:

• refine failed-count derivation inside the existing phase22 bindings surface
• ensure failed count increments only from terminal failure conditions
• add bounded local verification artifact
• preserve current Running Tasks and Tasks Completed derivations unchanged unless required for consistency

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

Tasks Failed must count terminal failure only.

Accepted failure signals:

• task.failed
• task.cancelled
• task.canceled
• status failed
• status error

Rejected for failed count:

• task.completed
• status done
• status complete
• status completed
• queued
• started
• running
• unknown events

Duplicate terminal failure for same task must not double count.

Terminal success for same task must never increment failed count unless explicitly selected as the controlling terminal interpretation in verification.

If terminal failure arrives before non-terminal events:
failed count must remain valid and task must never later be double-counted.

────────────────────────────────

STATE MODEL

Use bounded task identity tracking.

Preferred approach:

failedTaskIds = Set()

Rules:

On terminal failure for task_id:
  if task_id not already in failedTaskIds
    add task_id
    failedCount += 1

On duplicate terminal failure:
  no change

On completed terminal:
  do not increment failedCount

On non-terminal events:
  no increment

This must remain deterministic under replay.

────────────────────────────────

REQUIRED VERIFICATION CASES

• created -> started -> failed
• started -> failed
• failed -> started
• duplicate failed
• created -> completed
• created -> cancelled
• completed -> failed (define and verify intended behavior explicitly)
• unknown event ignored
• multi-task overlap with mixed success/failure

Success requirement:

Failed count advances only on first valid terminal failure per task.

────────────────────────────────

COMMIT RULE

One file only for first implementation pass.
One hypothesis only.
One bounded verification pass after implementation.

────────────────────────────────

SUCCESS CONDITION

Tasks Failed derivation is hardened deterministically inside the existing telemetry surface with no layout, transport, or authority change.

