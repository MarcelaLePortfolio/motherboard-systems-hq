
# Phase 717 Recent Tasks Density Reduced

Changed only the confirmed renderer file:

- public/js/phase530_visible_panels_bridge.js

What changed:

- Removed inline expandable task explanation details from Recent Tasks cards.

- Removed inline expandable advanced JSON trace blocks from Recent Tasks cards.

- Replaced both with compact audit/evidence pointers.

- Preserved lifecycle badge.

- Preserved Requeue control.

- Preserved Retry differently control.

- Preserved renderer-scoped containment.

- Preserved /execution-evidence.html as read-only forensic/audit surface.

Boundary preserved:

- no broad CSS changes

- no execution coupling

- no chat coupling

- no retry contract changes

- no database schema changes

