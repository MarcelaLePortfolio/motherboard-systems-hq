PHASE 62B — NEXT TELEMETRY TARGET
Running Tasks Metric Hydration
Date: 2026-03-16

────────────────────────────────

OBJECTIVE

Hydrate the "Running Tasks" telemetry tile using the existing task-events stream without introducing any behavioral change.

This is a DATA ONLY change.

STRICT CONSTRAINTS:

NO layout mutation
NO reducer redesign
NO state model changes
NO new authority paths
NO database mutation
NO UI structural change

Telemetry hydration only.

Layout contract must remain passing.
Telemetry baseline must remain passing.

────────────────────────────────

EXPECTED SOURCE

/events/task-events SSE stream

Expected usable events:

task.created
task.started
task.running (if present)
task.completed
task.failed
task.cancelled

Primary identifiers:

task_id
run_id
ts
state

────────────────────────────────

DETERMINISTIC MODEL

Preferred model:

Maintain deterministic active set.

ADD on:

task.created
task.started
task.running (if exists)

REMOVE on:

task.completed
task.failed
task.cancelled

Running Tasks = size(activeTaskSet)

Properties:

Deterministic
Replay-safe
Drift-safe
Reducer-safe

Must work under replay validation.

────────────────────────────────

SAFETY REQUIREMENTS

Reducer must:

Ignore duplicate events
Ignore unknown states
Ignore out-of-order terminal events already resolved

Terminal events must always win.

If terminal event arrives before start:

System must still resolve correctly.

No mutation of existing reducer logic allowed.
Extend only through safe augmentation.

────────────────────────────────

VALIDATION CHECKLIST

Before commit:

Running tasks never negative
Running tasks returns to zero after full replay
No metric flicker during replay
No layout change detected
No reducer warnings introduced

Verification commands:

npm run telemetry:replay-check
npm run telemetry:drift-check
npm run layout:contract-check

All must pass.

────────────────────────────────

SUCCESS CONDITION

Running Tasks tile displays correct count.

No behavioral change.
No authority change.
No persistence change.
No UI structure change.

Telemetry corridor moves closer to completion.

