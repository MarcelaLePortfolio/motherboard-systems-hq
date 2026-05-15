
# PHASE 719 — DISABLE ACTIVE PHASE530 STALE FETCHES

## PURPOSE

Disable the exact active stale Phase 530 fetch blocks discovered by live local/served inspection.

## ACTIVE STALE BLOCKS FOUND

`public/js/phase530_visible_panels_bridge.js`

- line 671: `getJson("/api/agents")`

- line 685: `getJson("/api/activity-graph")`

## PRESERVED ACTIVE BLOCK

The task fetch remains active and untouched:

- `getJson("/api/tasks?limit=12")`

## SAFETY

This patch does not modify:

- `/api/tasks`

- Recent Tasks rendering

- retry/requeue behavior

- artifact preview route

- iframe rendering

- worker artifact generation

- artifact persistence

- database schema

