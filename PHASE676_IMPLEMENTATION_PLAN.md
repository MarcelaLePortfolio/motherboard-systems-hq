# Phase 676 — Confirmed Retry Button Plan

Goal:
- Add a Retry button to GuidancePanel items with task context.
- Require explicit operator confirmation before execution.

Scope:
- UI only (app/components/GuidancePanel.tsx).
- Use existing POST /api/tasks/create retry payload.
- No backend changes.

Behavior:
- Button appears only if item.task_id exists.
- On click:
  1. Show confirm dialog: "Retry this task?"
  2. If confirmed → POST retry payload
  3. Refresh guidance

Constraints:
- No auto execution
- No background retry
- Must be user-confirmed

Success Criteria:
- Button renders for execution + retry guidance items
- Clicking without confirm does nothing
- Confirmed retry creates a new task
- /api/guidance updates accordingly
- UI remains stable
