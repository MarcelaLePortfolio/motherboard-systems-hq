PHASE 628 COMPLETE

Confirmed:
- Dashboard task rows expose data-task-row and data-task-id.
- Task row click sets window.selectedTaskId.
- Task row click dispatches execution-inspector:selected-task.
- Execution Inspector listens for selected task events.
- Execution Inspector filters /api/tasks rows by selectedTaskId when present.
- /api/tasks remains healthy.
- task-events SSE route is live again.
- Restored DB compatibility columns after Docker/Postgres recovery:
  - task_events.ts
  - task_events.actor
  - task_events.run_id
  - task_events.status
  - task_events.cursor
- SSE now emits hello without stream bootstrap/query errors.
- No worker, execution lifecycle, retry, or requeue behavior changed.

Result:
Execution Inspector connection path is restored and selection bridge is complete.

System state:
Stable and ready for next corridor.
