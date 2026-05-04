# Phase 673 — Next Vector: Operator Action Layer

Status: READY

Current State:
- System detects issues ✔
- System explains issues ✔
- System surfaces issues clearly ✔

Gap:
- Operator still has to manually translate guidance → action.

Objective:
Move from:
  awareness → manual reaction

To:
  awareness → assisted action

Focus Areas:

1. Action Binding
- Map guidance → specific actions
  examples:
    execution failure → "Retry Task"
    retries present → "Inspect Retry Chain"
    queue backlog → "Review Queue"

2. Inline Action Controls (UI ONLY)
- Add buttons inside GuidancePanel items:
  - "View"
  - "Retry"
  - "Inspect"
- These call EXISTING endpoints:
  - /api/delegate-task
  - /api/tasks
- No new backend logic

3. Context Passing
- When clicking action:
  - carry task_id or subsystem context
- Use existing routing patterns

4. Safety Constraints
- No auto-execution
- Operator must click
- No mutation to pipeline logic

Goal:
Turn guidance into **one-click next steps**

Result:
system → guidance → action → execution

You move from:
observer → operator

