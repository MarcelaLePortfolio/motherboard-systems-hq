Phase 20 – Task Events SSE (COMPLETE)

Status:
- Postgres-backed task_events table active
- /api/tasks/create|complete|fail|cancel write events
- /events/task-events SSE streams historical + live events
- Heartbeat + cursor confirmed stable
- API payload parsing bug fixed (string body issue)

Golden tag:
- v20.0-task-events-sse-ok

Next phase:
- Phase 21: Task runner → task_events unification
- OR Phase 21: Dashboard consumes task-events SSE instead of ops/reflections
