# Phase 664 — Confirmed UI Target

Status: TARGET_CONFIRMED

Primary active UI file:
- public/index.html

Primary guidance client script:
- public/js/operatorGuidance.sse.js

Reason:
- public/index.html contains the live Operator Guidance panel
- public/index.html loads js/operatorGuidance.sse.js
- Backup dashboard files are not the active patch target

Next safe action:
- Inspect exact insertion points before adding a read-only history placeholder.
