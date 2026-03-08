# Phase 58B — Stability Fix Checkpoint

## Objective
Stabilize the dashboard during Phase 58B probe lifecycle visibility work without expanding architecture.

## Problem Observed
The dashboard container repeatedly crashed with Node heap out-of-memory errors while the dashboard was open.

Observed failure pattern:
- `/api/health` would initially return `200`
- dashboard rendered
- `/events/task-events` replayed the same historical probe event repeatedly
- memory climbed until the dashboard process crashed

## Root Cause
`/events/task-events` advanced its replay cursor incorrectly.

The SSE route used `created_at > to_timestamp($1 / 1000.0)` for paging but updated the in-memory cursor in a way that allowed the same row to be selected repeatedly. This caused:
- duplicate `task.event` delivery
- repeated frontend processing
- repeated DOM/event work
- eventual dashboard container OOM

## Fix Applied
Updated `server/routes/task-events-sse.mjs` so that:
- the cursor advances from `created_at`
- the cursor is bumped to `createdAtMs + 1`
- historical replay stops after the initial event
- subsequent frames become heartbeats instead of duplicate task events

## Validation
Validated after rebuild and restart:

### Health
- `curl http://127.0.0.1:8080/api/health` → `{"ok":true}`

### SSE behavior
- `/events/ops` returns hello + state
- `/events/reflections` returns hello + empty state
- `/events/task-events` now returns:
  - one probe event
  - then heartbeats
  - no replay flood

### UI behavior
Dashboard now shows:
- Probe Event Stream connected
- Probe lifecycle card visible
- `run policy.probe.run`
- lifecycle state rendered as Running
- grouped heartbeat rows instead of event spam

### Memory
Observed dashboard container memory:
- ~18.54 MiB
- stable
- far below prior runaway heap state

## Result
Phase 58B is now stable enough to continue.

## Remaining UI Gaps
Not blockers for this stability fix:
- reflections surface still shows disconnected / waiting state
- empty-state polish still needed
- overall operator hierarchy can still be improved

## Next Recommended Focus
Proceed to Phase 58C:
- intentional empty states
- clearer idle/loading/unavailable distinction
- reduce visual debug-surface feel
