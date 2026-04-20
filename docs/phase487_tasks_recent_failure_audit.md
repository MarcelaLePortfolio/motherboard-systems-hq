# Phase 487 — /tasks/recent Failure Audit

## Classification
SAFE — Read-only, bounded route/data-shape audit

## Purpose
The server now boots successfully.

Current live route state shows:

- `/` returns 200
- `/logs/recent` returns 200
- `/tasks/recent` returns 500

Before any mutation, this step verifies whether the tasks route is failing because the live database table shape does not match the query shape.

## Audit questions
1. What columns does `routes/api/tasks.ts` request?
2. What columns actually exist on `task_events` in the restored database?
3. Is the next move a narrow route-alignment fix?

## Status
READY
