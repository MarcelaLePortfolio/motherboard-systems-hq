Task History UI Audit (Execution Step 2)

Objective:
Begin concrete enforcement of telemetry scope separation by auditing and cleaning Task History UI implementation to remove any system-level metric leakage.

──────────────────────────────

AUDIT TARGETS

1. Task History Component
- Identify any rendering of:
  - system health metrics
  - worker status
  - API/db/global execution signals
- These MUST be removed if present

2. Allowed Rendering Scope (Task History ONLY)
- task_id
- task state transitions
- timestamps (created_at, updated_at, completed_at)
- retry count / failure metadata
- task-specific logs only

──────────────────────────────

REMOVAL RULE
- Any data that reflects system-wide state is invalid in this layer
- No shared components between System Metrics and Task History

──────────────────────────────

VALIDATION CHECK
- Task History must not reference:
  - global worker state
  - system health panels
  - aggregated telemetry summaries

──────────────────────────────

STATUS
Phase: UI Enforcement Pass 2
Scope: Task History Isolation
Backend: No changes
