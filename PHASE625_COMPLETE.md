PHASE 625 COMPLETE

Summary:
- Read-only guidance UI has been surfaced in the real dashboard task widget.
- The unsafe overwrite was reverted.
- The final guidance patch was limited to a micro-patch.
- Existing render, polling, fetch, SSE, and execution behavior were preserved.
- Verification confirms renderGuidance(t) exists and is called from the task row template.

Next safe corridor:
Phase 626 should visually verify guidance rendering in the browser using a live or mocked task payload containing guidance.
