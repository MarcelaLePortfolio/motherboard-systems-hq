PHASE 626 DB RESTORED

Status:
- Docker Desktop daemon recovered.
- Dashboard container is running.
- Postgres was recreated during Docker recovery.
- Missing tasks/task_events tables were restored manually.
- /api/tasks now returns ok:true.

Next:
- Seed one completed task and matching task.completed event with guidance payload.
- Verify /api/tasks exposes guidance.
- Visually confirm dashboard renders guidance.
