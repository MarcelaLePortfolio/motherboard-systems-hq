
# Phase 717 — Revert Bad Recent Logs Removal

Status: REVERTED

Reason:

- Commit 917a1287 attempted to remove the embedded Recent Logs panel.

- The patch accidentally collapsed public/js/phase530_visible_panels_bridge.js from the full renderer into a one-line artifact.

- This violated safe renderer-scoped patch discipline.

Recovery:

- Reverted 917a1287 immediately.

- Do not continue the Recent Logs removal approach from that failed patch.

- Reattempt only with a smaller, verified diff after confirming renderer line count and exact function bounds.

Preserved objective:

- Recent Logs should still eventually leave the overall Recent Tasks card.

- Inspect logs should remain task-scoped.

- Any future removal must preserve the full renderer file.

