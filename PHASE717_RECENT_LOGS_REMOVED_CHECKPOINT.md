
# Phase 717 — Recent Logs Shell Removal Checkpoint

Status: STABLE

Checkpoint summary:

- Embedded Recent Logs HTML wrapper removed from public/index.html

- Recent Tasks now occupies the full lifecycle card surface

- Per-task Inspect logs modal preserved and functioning

- Renderer integrity preserved after prior revert event

- phase530_visible_panels_bridge.js remains structurally intact

- Dashboard serving correctly on localhost:3000

- Docker runtime healthy

- External archive workflow validated

Important recovery history:

- Commit 917a1287 previously corrupted renderer structure and was reverted

- Subsequent removal work used narrow renderer-scoped edits only

- HTML shell removal completed safely with minimal diff

- Recent Logs lifecycle functionality intentionally consolidated into task-scoped modal inspection

Preserved architecture:

- Recent Tasks remains primary lifecycle execution surface

- Inspect details remains read-only

- Inspect trace remains read-only

- Inspect logs remains task-scoped and modal-based

- Static evidence surface remains secondary audit surface

- Retry/requeue controls remain operator-triggered only

Current authoritative state:

- public/index.html no longer contains Recent Logs shell

- recentLogs DOM node removed from served dashboard HTML

- Recent Tasks fills lifecycle workspace card

- Task-specific logs accessible through Inspect logs chips

