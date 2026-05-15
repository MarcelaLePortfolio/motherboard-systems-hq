
# PHASE 719 — DISABLE STALE PHASE530 CALLS v2

## PURPOSE

The prior stale endpoint cleanup did not stop active browser calls from `phase530_visible_panels_bridge.js`.

Remaining console errors:

- `/api/agents` 404

- `/api/activity-graph` 404

- HTML fallback parsed as JSON by Phase 530 bridge

## CLASSIFICATION

The remaining issue is still frontend console hygiene.

## SAFETY

This patch only disables stale Phase 530 fetch calls to retired endpoints.

It does not modify:

- `/api/tasks`

- `/events/task-events`

- artifact preview route

- retry/requeue behavior

- worker artifact generation

- artifact persistence

- database schema

- iframe preview rendering

