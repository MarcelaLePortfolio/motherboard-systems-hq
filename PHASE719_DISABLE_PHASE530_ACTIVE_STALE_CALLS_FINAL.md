
# PHASE 719 — DISABLE PHASE530 ACTIVE STALE CALLS FINAL

## PURPOSE

Disable the exact active stale Phase 530 frontend calls still producing browser console noise.

## TARGET FILE

`public/js/phase530_visible_panels_bridge.js`

## ACTIVE STALE CALLS

The browser still executes:

- `getJson("/api/agents")`

- `getJson("/api/activity-graph")`

## PRESERVED CALL

The active Recent Tasks fetch remains untouched:

- `getJson("/api/tasks?limit=12")`

## SAFETY

This patch does not modify:

- worker artifact generation

- artifact persistence

- retry/requeue behavior

- task execution routes

- `/api/tasks`

- `/events/task-events`

- artifact preview route

- iframe preview rendering

- database schema

