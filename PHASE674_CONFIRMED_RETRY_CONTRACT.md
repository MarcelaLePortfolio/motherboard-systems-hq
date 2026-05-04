# Phase 674 — Confirmed Retry Contract

Status: CONFIRMED ENOUGH FOR A CONTROLLED PROBE

Confirmed facts:
- Existing mutation route: POST /api/tasks/create
- Worker policy resolver reads retry fields from task.payload:
  - retry_of_task_id
  - execution_mode
  - cache_policy
  - memory_scope
- retry_execution_router supports:
  - strategy: fresh-context
  - execution_mode: rebuild_context
  - cache_policy: bypass
  - memory_scope: reset_partial

Safe retry-create payload shape:

{
  "task_id": "retry_<unique>",
  "title": "Retry <original_task_id>",
  "status": "queued",
  "kind": "retry",
  "payload": {
    "retry_of_task_id": "<original_task_id>",
    "execution_mode": "rebuild_context",
    "cache_policy": "bypass",
    "memory_scope": "reset_partial",
    "strategy": "fresh-context"
  },
  "source": "operator-guidance-ui"
}

Constraint:
- UI must not call this until a controlled curl probe validates creation and worker compatibility.
