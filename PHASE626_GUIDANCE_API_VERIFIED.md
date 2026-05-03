PHASE 626 GUIDANCE API VERIFIED

Confirmed:
- Docker daemon recovered.
- Dashboard stack running.
- DB schema restored.
- Seed task inserted.
- task.completed guidance event inserted.
- /api/tasks exposes top-level guidance.
- Guidance payload is ready for dashboard visual inspection.

Visual check:
Open http://localhost:3000 and confirm the task row shows:
- warning
- Guidance is exposed through /api/tasks for UI verification.
- expandable details/explanation
