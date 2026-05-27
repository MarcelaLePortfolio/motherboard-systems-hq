Start point
- Tag: v21.0-dashboard-task-events-sse-verified

Status
- Phase 21 is complete and container-verified.
- /events/task-events SSE stream is verified.

Next objective (Phase 19/20 follow-on)
- Wire real task lifecycle writes into task_events so /events/task-events reflects live system behavior.

Implementation target
- Introduce a central emit helper for task_events writes.
- Use that helper across:
  - task create
  - task update
  - task complete
  - task fail

Success criteria
- Creating/updating/completing/failing a task produces corresponding task_events rows.
- /events/task-events immediately streams those events in real time (no manual inserts).
