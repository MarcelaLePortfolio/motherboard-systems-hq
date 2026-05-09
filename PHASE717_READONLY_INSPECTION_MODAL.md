
# Phase 717 Read-Only Inspection Modal

Implemented after external backup source-b25e7532.tar.gz and anchor discovery at 50be4cce.

Changed file:

- public/js/phase530_visible_panels_bridge.js

Behavior:

- Replaces passive compact evidence notices with clickable chips.

- "Inspect details" opens a read-only modal with task explanation content.

- "Inspect trace" opens a read-only modal with advanced trace content.

- Modal explicitly states it does not trigger execution, retry, or mutation.

- Requeue and Retry differently controls remain unchanged.

- /execution-evidence.html remains the heavyweight secondary audit surface.

Boundary:

- no broad CSS changes

- no DB changes

- no API contract changes

- no chat coupling

- no execution coupling

