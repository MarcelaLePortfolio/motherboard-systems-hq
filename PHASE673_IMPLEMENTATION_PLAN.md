# Phase 673 — Operator Action Layer Implementation Plan

Scope:
- Modify ONLY app/components/GuidancePanel.tsx
- UI-only changes
- No backend, API contract, execution, worker, scheduler, or DB changes

Implementation:

1. Add Action Mapping (frontend only)
- Map guidance.subsystem + type → action set

Example mapping:
- execution + critical → ["Retry Task", "View Tasks"]
- task-retries + warning → ["Inspect Retries", "View Tasks"]
- task-queue + warning → ["Review Queue"]

2. Render Inline Action Buttons
- Add buttons under each guidance item:
  - View
  - Retry (only for execution-related)
  - Inspect (for retries/queue)
- Style:
  - small
  - clearly clickable
  - secondary but visible

3. Wire to Existing Endpoints
- View → navigate to /tasks or existing dashboard route
- Retry → POST /api/delegate-task (reuse existing payload pattern)
- Inspect → filter or route using existing UI state

4. Context Passing
- Use:
  - subsystem
  - (if available later: task_id)
- Keep logic defensive (UI should not break if context missing)

5. Safety Rules
- No automatic execution
- All actions require explicit click
- No mutation of backend logic

Validation:

- Rebuild containers
- Confirm:
  - /api/guidance still returns HTTP 200
  - UI renders buttons under guidance items
  - Clicking buttons does not crash UI
  - Existing flows (Execution Inspector, Tasks list) still function

Success Criteria:

- Guidance items now include actionable controls
- Operator can move from signal → action in one step
- System behavior remains unchanged

Outcome:

You upgrade from:
"System tells you what to do"

To:
"System helps you do it"

