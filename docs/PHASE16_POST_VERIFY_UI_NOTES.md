# Phase 16 UI HUD Bubbles — Keep or Remove?

Decision: **Keep the floating corner HUD bubbles for now** while wiring is still in progress, then remove/relocate them during the post-wiring UI cleanup pass.

Rationale:
- During active wiring, the bubbles provide fast, always-visible signal (SSE connected, owner=on, last state).
- Removing them now risks slowing diagnosis and creating churn while other subsystems are still moving.
- The current issue is UX obstruction, not core correctness; we can mitigate without disabling.

Immediate mitigation (no feature work, no debug toggle):
- Reduce obstruction by:
  - Lowering opacity a bit
  - Shrinking max height
  - Allowing collapse/minimize
  - Ensuring they don't overlap key panels (move to bottom edge, or tighter margin)
  - Making them pointer-events:none except for a small header/collapse handle

Cleanup later (after wiring is stable):
- Route the reflections stream into the static "System Reflections" panel.
- Keep a small, non-obstructive status pill (connected/disconnected + lastAt), but remove the big floating stream.
- Optional ergonomic enhancement: add a Debug UI toggle that enables the HUD overlays when needed.
