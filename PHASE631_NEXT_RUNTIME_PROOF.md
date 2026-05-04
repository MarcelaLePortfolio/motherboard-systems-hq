PHASE 631 — LIVE RUNTIME PROOF

Goal:
Run one fresh live task through the restored stack and verify both guidance layers on real runtime data.

Verify:
- task created
- worker processes task
- task.completed emitted
- /api/tasks updates
- dashboard task widget shows guidance
- task row selection focuses Execution Inspector
- Execution Inspector shows guidance
- task-events SSE remains connected without errors

Rules:
- Verification only.
- No new feature patches.
- No execution lifecycle changes.
