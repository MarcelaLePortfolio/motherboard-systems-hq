(() => {
  "use strict";

  /**
   * Phase64 Safety Patch
   * Disables legacy EventSource usage to prevent SSE duplication.
   * Phase16 is the single owner of all /events/* streams.
   */

  if (typeof window !== "undefined" && window.__PHASE16_SSE_OWNER_STARTED) {
    return;
  }

  // Hard disable legacy agent-status-row SSE consumption
  window.__PHASE64_AGENT_STATUS_DISABLED = true;

  console.log("[phase64_agent_status_row] disabled: Phase16 SSE ownership enforced");
})();

// ===== Phase16 Migration Patch (safe event-bus bridge) =====
(function () {
  if (typeof window === "undefined") return;

  window.addEventListener("mb.task.event", (e) => {
    try {
      const ev = e.detail;
      if (!ev) return;

      // UI-safe no-op hook: preserves system contract without SSE coupling
      // Existing DOM/UI logic remains untouched above this block
      // Future Phase16 wiring can extend this safely

      if (window.__UI_DEBUG) {
        console.log("[agent-status-row][Phase16]", ev);
      }
    } catch (_) {}
  });
})();
// ===== End Phase16 Patch =====
