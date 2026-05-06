# Phase 704 — Execution Inspector SSE Endpoint Fixed

The remaining “Connection error” label was caused by frontend stream wiring, not the backend execution path.

Verified facts before fix:
- `/api/tasks?limit=12` returned live completed task data.
- worker claimed and completed the proof task.
- `tasks`, `task_events`, and `run_view` were valid.
- `/events/task-events` returned HTTP 200.
- `/events/tasks` returned HTTP 404.

Fix:
- Repointed Execution Inspector stream usage from `/events/tasks` to `/events/task-events`.
- Adjusted error wording so a transient SSE error does not falsely imply execution backend failure.
