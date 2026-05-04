# Phase 675 — Guidance Task Context Binding Plan

Goal:
- Add task-level context to guidance output so future UI actions can target the correct task safely.

Scope:
- Backend guidance payload enrichment only.
- Backward-compatible API shape.
- No execution mutation.
- No retry button yet.

Target fields:
- task_id
- source_task_id
- related_task_ids
- failure_count
- retry_count
- queued_count

Rules:
- Guidance items must remain readable without these fields.
- Existing UI must not break.
- No POST actions introduced.

Success Criteria:
- /api/guidance returns the same guidance messages plus task context metadata.
- Existing dashboard still renders normally.
- Future retry buttons can target a specific failed task.
