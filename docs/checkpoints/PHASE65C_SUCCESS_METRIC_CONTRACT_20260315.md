PHASE 65C — SUCCESS RATE OWNERSHIP TRANSFER CONTRACT
Date: 2026-03-15

OBJECTIVE

Transfer metric-success ownership from agent-status-row.js to telemetry layer.

STRICT RULES

NO layout mutation.
NO ID changes.
NO wrapper additions.
NO script mount order changes.
NO Queue Depth hydration yet.

SOURCE OF TRUTH

/events/task-events SSE stream

INPUT SIGNALS

Terminal success:
task.completed
task.complete
task.done
task.success

Terminal failure:
task.failed
task.error
task.cancelled
task.canceled
task.timed_out
task.timeout

METRIC DEFINITION

Success Rate = completed / (completed + failed)

DISPLAY

Rounded whole-number percentage.
If no terminal events observed, display em dash.

OWNERSHIP RESULT

agent-status-row.js must stop writing metric-success.
telemetry module becomes sole writer for metric-success.

SUCCESS CRITERIA

metric-success still renders correctly.
metric-tasks remains correct.
No layout drift.
No tab/workspace regression.
