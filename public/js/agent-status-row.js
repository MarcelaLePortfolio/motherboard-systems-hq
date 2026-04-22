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
