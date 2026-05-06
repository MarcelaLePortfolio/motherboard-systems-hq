# Phase 704 — Inspector UI Connection Error Audit

This audit checks whether the remaining “connection error” label is caused by frontend SSE/status wiring rather than the already-proven execution backend.

Known before this audit:
- Docker runtime is authoritative again.
- `/api/tasks?limit=12` returned the live proof task.
- Worker claimed and completed the proof task.
- `tasks`, `task_events`, and `run_view` all contain the proof path.

This audit inspects:
- frontend strings that emit connection-error/disconnected labels
- dashboard script loading
- inspector JS files
- `/events/task-events`
- `/events/tasks`
- `/events/operator-guidance`
