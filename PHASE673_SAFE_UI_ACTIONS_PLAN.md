# Phase 673 — Safe UI Actions Plan

Scope:
- Add UI-only, non-mutating action buttons to GuidancePanel.
- No POST requests.
- No retry actions.
- No backend, API contract, worker, scheduler, DB, or execution changes.

Safe Controls:
- View Tasks → scroll/navigate operator toward task surface when route exists.
- Inspect Guidance → refresh current guidance from /api/guidance.
- Copy Action → copy suggested_action text to clipboard.

Success Criteria:
- Buttons render under guidance items.
- Clicking buttons does not mutate system state.
- /api/guidance remains HTTP 200.
- Dashboard remains stable.
