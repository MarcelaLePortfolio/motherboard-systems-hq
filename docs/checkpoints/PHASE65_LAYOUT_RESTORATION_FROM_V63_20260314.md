STATE NOTE — PHASE 65 LAYOUT RESTORATION
Date: 2026-03-14

ACTION

Restore dashboard layout-bearing files from:

v63.0-telemetry-integration-golden

RATIONALE

No fixing forward.
Layout must be restored from a known good checkpoint rather than patched.

FILES RESTORED

- public/dashboard.html
- public/css/dashboard.css
- public/js/phase61_tabs_workspace.js
- public/js/phase61_recent_history_wire.js
- public/js/agent-status-row.js
- public/js/dashboard-bundle-entry.js

REQUIRED FOLLOW-UP

- run layout/script guards
- rebuild dashboard container
- verify restored layout in browser
- only after visual confirmation may future protection work continue

RULE

Future handoffs must explicitly state:

- protected surfaces
- unprotected surfaces
- protections still addable without limiting future work
- confidence level

No claims of full protection unless composition-level layout invariants are also covered.
