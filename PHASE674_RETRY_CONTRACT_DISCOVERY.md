# Phase 674 — Retry Contract Discovery

Status: REQUIRED BEFORE IMPLEMENTATION

Findings:
- Task mutation endpoints exist:
  - POST /api/tasks/create
  - POST /api/tasks/complete
  - POST /api/tasks/fail
- Retry is referenced in orchestration layer (task.retry), not UI layer.
- No confirmed UI-safe retry endpoint yet.

Next Step:
- Identify exact payload used for retry:
  - required fields (task_id, run_id, retry_of_task_id, strategy, etc.)
  - expected endpoint (create vs delegate-taskspec)

Constraint:
- Do NOT implement retry UI until payload is confirmed.

Goal:
Establish a deterministic, safe retry contract before enabling operator-triggered execution.
