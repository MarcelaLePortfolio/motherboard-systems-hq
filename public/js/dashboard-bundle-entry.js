import "./sse-heartbeat-shim.js";
import "./heartbeat-stale-indicator.js";
// Phase 11 – Unified dashboard bundle entrypoint

// Core dashboard status + tiles
import "./dashboard-status.js";

// Phase 15/16 boundary: disable optional SSE (OPS + Reflections) until backends exist
if (typeof window !== "undefined" && typeof window.__DISABLE_OPTIONAL_SSE === "undefined") {
  window.__DISABLE_OPTIONAL_SSE = false;
}

import "./agent-status-row.js";

// OPS / PM2 status + SSE wiring
import "./dashboard-broadcast.js";
import "./ops-status-widget.js";
import "./ops-globals-bridge.js";
import "./ops-pill-state.js";
import "./dashboard-tasks-widget.js";

// Matilda chat console wiring
import "./matilda-chat-console.js";

// TEMP: dashboard graph disabled until canvas is present on all pages
// import "./dashboard-graph.js";


// Phase 22: task-events live UI
import "./task-events-sse-client.js";
import "./phase22_task_delegation_live_bindings.js";
