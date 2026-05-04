PHASE 629 COMPLETE

Confirmed:
- Execution Inspector no longer shows “Untitled Event”.
- Safe read-only title fallback added:
  - r.title → r.task_title → r.name → "Task {task_id}" → "Untitled Event"
- No mutation of task or event data.
- No impact to execution pipeline, worker, retry, or routing layers.
- UI-only enhancement within inspector rendering path.

Result:
Execution Inspector now resolves human-readable titles even for seeded or minimal task_events payloads.

System state:
Stable.
No regressions observed.
Ready for next corridor.

Note:
This is a presentation-layer patch only. True canonical title remains sourced from /api/tasks.
