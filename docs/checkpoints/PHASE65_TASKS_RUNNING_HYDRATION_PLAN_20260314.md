STATE NOTE — PHASE 65 TELEMETRY HYDRATION
Tasks Running Metric Implementation Plan
Date: 2026-03-14

OBJECTIVE

Hydrate the "Tasks Running" metric tile using existing task lifecycle data without altering layout or script mount order.

RULES

DATA BINDING ONLY
NO layout mutation
NO ID changes
NO container movement
NO CSS edits
NO script order changes

All protection guards must remain passing.

EXPECTED DATA SOURCES

/events/task-events SSE stream
/api/tasks recent tasks endpoint

Expected lifecycle states:

created
queued
running
completed
failed
cancelled

PROPOSED MODEL

Running Tasks = count(tasks where state = running OR queued)

Authoritative model (preferred):

Maintain active task set:

ADD on:
task.started
task.queued

REMOVE on:
task.completed
task.failed
task.cancelled

Metric value:

Running Tasks = size(activeTaskSet)

IMPLEMENTATION TARGET FILES

public/js/phase61_recent_history_wire.js
public/js/phase61_tabs_workspace.js

If needed:

public/js/phase65_metrics_tasks_running.js (new isolated metric binder)

SAFETY STRATEGY

Metric must:

Fail safe to 0 if no events present
Ignore malformed events
Ignore duplicate lifecycle transitions

VALIDATION CHECKS

Layout verifier must pass
Protection corridor scripts must pass
Dashboard must remain interactive
Idle state must show 0 running tasks

TEST PLAN

1 Observe idle dashboard (expect 0)
2 Start task (expect increment)
3 Complete task (expect decrement)
4 Verify no negative values possible

SUCCESS CRITERIA

Tasks Running reflects live runtime state
No layout diffs
No interactivity regressions
All guards passing

Phase 65 telemetry hydration continues after this metric.

