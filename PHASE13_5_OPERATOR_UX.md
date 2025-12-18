# Phase 13.5 — Operator UX (Dashboard-only)

Adds a **pure dashboard-side** operator affordance layer:

## Included
- Fixed operator bar (API cue, Chat/Task focus, reload)
- Toasts for API + runtime errors
- Keyboard shortcuts:
  - `/` focus chat
  - `t` focus task
  - `r` reload

## Guarantees
- No backend changes
- No DB changes
- Best-effort DOM hooks only
- Safe to remove or ignore

## Wiring
Include on dashboard:

<link rel="stylesheet" href="/css/phase13_5_operator_ux.css" />
<script defer src="/js/phase13_5_operator_ux.js"></script>
