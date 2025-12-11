// Phase 11 – Unified dashboard bundle entrypoint

// Core dashboard status + tiles
import "./dashboard-status.js";
import "./agent-status-row.js";

// OPS / PM2 status + SSE wiring
import "./dashboard-broadcast.js";
import "./ops-status-widget.js";
import "./ops-globals-bridge.js";
import "./ops-pill-state.js";

// Matilda chat console wiring
import "./matilda-chat-console.js";

// Task Delegation wiring
import "./dashboard-delegation.js";

// TEMP: dashboard graph disabled until canvas is present on all pages
// import "./dashboard-graph.js";
