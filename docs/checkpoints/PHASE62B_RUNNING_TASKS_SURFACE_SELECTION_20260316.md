PHASE 62B — RUNNING TASKS SURFACE SELECTION
Date: 2026-03-16

────────────────────────────────

SELECTION

Primary implementation surface:

public/js/phase22_task_delegation_live_bindings.js

Reason:

This file already maintains task state derived from mb.task.event updates and already computes status-based counters from task-events-driven data.

It is the narrowest existing telemetry derivation surface for adding a runningTasks count without mutating:

• SSE transport
• server routes
• layout structure
• reducer ownership outside current task UI derivation

────────────────────────────────

SECONDARY REFERENCE ONLY

public/js/task-events-sse-client.js

Reason:

This is the task-events ingestion and dispatch surface.
Use as reference only unless strictly required.

Do not implement first-pass runningTasks derivation here if it can be completed inside the existing UI derivation layer.

────────────────────────────────

IMPLEMENTATION RULE

First code change must touch ONE primary derivation file only.

Allowed first-pass target:

• add isolated runningTasks derivation inside public/js/phase22_task_delegation_live_bindings.js

Not allowed in first pass:

• edits to server/routes/task-events-sse.mjs
• edits to layout HTML
• edits to public/dashboard.html
• multi-surface telemetry refactor
• reducer redesign

────────────────────────────────

SUCCESS CONDITION

One bounded implementation surface has been selected.

Next work may proceed as a narrow telemetry-only code change.

