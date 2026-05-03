PHASE 627 — EXECUTION WIRING STATUS

Current verified execution wiring:
- Task database restored.
- Worker container is running.
- Dashboard container is running.
- /api/tasks is healthy.
- task.completed guidance payload reaches /api/tasks.
- Dashboard task widget renders guidance after API + UI mapping correction.
- Phase 626 is complete.

Current issue:
- Execution Inspector appears disconnected from the live task/run UI surface.
- This is a UI wiring issue, not evidence that execution pipeline is broken.
- Execution Inspector should be treated as read-only consumer until proven otherwise.

Known working path:
task.completed → task_events → /api/tasks → dashboard task widget → visible guidance

Likely disconnected path:
live task/run selection → Execution Inspector panel

Next safe corridor:
PHASE 627 — Reconnect Execution Inspector as a read-only live task/run consumer.

Rules:
- Do not mutate worker logic.
- Do not mutate task execution lifecycle.
- Do not alter retry/requeue behavior.
- Inspect current Execution Inspector mount and data source first.
- Patch only the UI bridge needed to pass selected/live task data into the inspector.
