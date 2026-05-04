# Phase 672 — Guidance UX Refinement Implementation Plan

Scope:
- Edit only app/components/GuidancePanel.tsx.
- No backend changes.
- No API contract changes.
- No execution, worker, scheduler, or DB changes.

Implementation:
1. Add severity badge styling.
2. Add tinted cards per guidance type.
3. Make suggested_action visually stronger.
4. Add clearer empty healthy state.
5. Preserve existing SSE + polling behavior.

Validation:
- Rebuild containers.
- Confirm /api/guidance still returns HTTP 200.
- Confirm dashboard visually shows CRITICAL and WARNING sections from test task.
