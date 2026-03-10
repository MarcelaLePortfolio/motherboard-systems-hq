# Phase 61.5 — Recent Tasks and Task History Wired
Date: 2026-03-10

## Objective
Wire Recent Tasks and Task History into the locked Telemetry Workspace without changing the protected Phase 61 layout structure.

## Result
Recent Tasks and Task History are now actively wired in the telemetry workspace.

### Recent Tasks
- reads from `/api/tasks?limit=12`
- renders inside `#recent-tasks-card`
- refreshes on interval
- refreshes after `mb.task.event`

### Task History
- reads from `/api/runs?limit=20`
- renders inside the Task History telemetry panel
- refreshes on interval
- refreshes after `mb.task.event`

## Layout Safety
The layout contract remained green throughout:
- metrics row intact
- workspace shell intact
- workspace grid intact
- Operator Workspace intact
- Telemetry Workspace intact
- Atlas band still full width

## Files Added / Changed
- `public/js/phase61_recent_history_wire.js`
- `public/dashboard.html`

## Relevant Commit
- `d20238e0` — Phase 61.5: wire Recent Tasks and Task History into telemetry workspace

## Current Status
Phase 61 dashboard is now:
- structurally locked
- runtime recoverable
- Task Events wired
- Recent Tasks wired
- Task History wired

## Rule Still In Force
Never fix forward.
If structural layout breaks:
1. restore checkpoint
2. verify layout contract
3. re-apply cleanly
