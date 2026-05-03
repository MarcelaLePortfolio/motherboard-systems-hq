PHASE 628 — NEXT CORRIDOR (EXECUTION INSPECTOR → LIVE SELECTION BRIDGE)

Current state:
- Phase 626: guidance pipeline verified end-to-end
- Phase 627: Execution Inspector renders guidance (read-only)
- Inspector currently polls /api/tasks and shows recent history
- Inspector is NOT yet wired to a selected task from the dashboard UI

Gap:
- No bridge between “task row click” → “Execution Inspector focus”
- Inspector acts as passive feed, not contextual viewer

Objective:
Reconnect Execution Inspector as a read-only contextual panel for the selected task.

Constraints:
- DO NOT modify worker logic
- DO NOT modify execution lifecycle
- DO NOT modify retry/requeue contracts
- UI-only patch
- Read-only data flow

Target behavior:
- Clicking a task row sets window.selectedTaskId
- Execution Inspector filters to that task_id
- Inspector shows:
  - status
  - id
  - outcome
  - explanation
  - guidance

Minimal patch strategy:
1. Capture task click in dashboard-tasks-widget.js
2. Store selectedTaskId globally
3. Modify inspector fetch/render to filter rows by selectedTaskId (if present)
4. Fallback to existing recent-history mode if no selection

Success criteria:
- Click task row → inspector updates to that task
- Guidance still renders
- No regression to retry/requeue
- No mutation to execution pipeline

System state:
Stable. Ready for UI bridge patch.
