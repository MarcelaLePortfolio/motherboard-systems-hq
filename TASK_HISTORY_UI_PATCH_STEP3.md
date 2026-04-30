Task History UI Patch (Execution Step 3)

Objective:
Apply concrete UI-level enforcement changes to remove system metric leakage and enforce strict task-scoped rendering.

──────────────────────────────

IMPLEMENTATION TARGET

TaskHistory Component (Frontend)

──────────────────────────────

CHANGES TO APPLY

1. REMOVE (if present)
- system health metrics display blocks
- worker status indicators
- API / DB / global execution panels
- any shared telemetry summary components

──────────────────────────────

2. KEEP ONLY
- task_id
- task status (queued | running | completed | failed)
- timestamps (created_at, updated_at, completed_at)
- retry count
- failure metadata
- task-specific logs

──────────────────────────────

3. ENFORCEMENT RULE
- This component must NOT import or reference System Metrics modules
- No shared telemetry state hooks allowed
- No global health context injection

──────────────────────────────

4. VALIDATION REQUIREMENT
After patch:
- Task History renders ONLY task-scoped data
- No system-wide signals appear in UI
- No duplication of metrics across layers

──────────────────────────────

STATUS
Phase: UI Enforcement Pass 3
Scope: Implementation Patch
Backend: No changes
