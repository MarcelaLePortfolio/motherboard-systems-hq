# Phase 670 — Operator Guidance UI Activation Plan

Goal:
- Surface existing guidance signals in the dashboard UI.
- No backend mutation.
- No API contract changes.
- Pure UI consumption + rendering.

Confirmed Inputs:
- GET /api/guidance
- Fields:
  - guidance[] (already sorted by severity)
  - type (info | warning | critical)
  - severity (numeric)
  - message
  - subsystem
  - suggested_action

UI Requirements:
1. Render guidance panel in dashboard
2. Group by severity:
   - critical (top, red)
   - warning (middle, yellow)
   - info (bottom, neutral)
3. Show:
   - message (primary)
   - subsystem (secondary label)
   - suggested_action (if present)
4. Live updates via polling (existing pattern)
5. Do not block or interfere with any existing UI components

Strict Constraints:
- Do NOT modify:
  - execution pipeline
  - worker
  - scheduler
  - database
- Do NOT introduce new API routes
- Do NOT change response structure

Success Criteria:
- Inserted failed task produces visible critical UI signal
- Retry task produces warning UI signal
- Clean system shows "all systems normal"

