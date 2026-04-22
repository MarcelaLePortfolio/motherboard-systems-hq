(() => {
  "use strict";

  /**
   * Phase64 Agent Activity Wire
   * SSE ownership is centralized under Phase16/Task Events system.
   *
   * This file intentionally disables direct EventSource creation to prevent
   * duplicate /events/task-events consumers.
   */

  if (typeof window !== "undefined" && window.__PHASE16_SSE_OWNER_STARTED) {
    return;
  }

  window.__PHASE64_AGENT_ACTIVITY_DISABLED = true;

  console.log("[phase64_agent_activity_wire] disabled: centralized SSE owner active");
})();
