# Phase 664 — Guidance History UI Placeholder

Status: DESIGN ONLY

Goal:
Add a read-only Operator Dashboard placeholder for guidance history.

Rules:
- No execution changes
- No worker changes
- No scheduler changes
- No DB writes
- No mutation actions
- UI consumes /api/guidance-history only

Validated dependency:
- Phase 663 guidance history is validated and tagged at phase663-guidance-history-validated.

Initial UI behavior:
- Show latest guidance history count
- Show most recent snapshot timestamp
- Show empty-state when history is unavailable
- Keep visual treatment secondary to active guidance

Next safe action:
- Locate active dashboard UI file before patching.
