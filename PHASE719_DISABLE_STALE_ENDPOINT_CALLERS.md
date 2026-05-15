
# PHASE 719 — DISABLE STALE ENDPOINT CALLERS

## PURPOSE

Reduce browser console clutter caused by deprecated frontend callers that still request retired/missing routes.

## OBSERVED NOISE

The remaining browser console errors include:

- `/api/agents` 404

- `/api/activity-graph` 404

- `/diagnostics/system-health` 404

- `/events/ops` 404

- `/events/reflections` 404

- `/events/tasks` 404

## SAFETY BOUNDARY

This patch must not modify:

- worker artifact generation

- artifact persistence

- retry/requeue behavior

- task execution routes

- `/api/tasks`

- `/events/task-events`

- artifact preview route

- iframe artifact rendering

- database schema

## CHANGE TYPE

Frontend console hygiene only.

