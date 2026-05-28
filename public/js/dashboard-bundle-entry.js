import "./sse-heartbeat-shim.js";
import "./heartbeat-stale-indicator.js";

import "./dashboard-status.js";

if (typeof window !== "undefined" && typeof window.__DISABLE_OPTIONAL_SSE === "undefined") {
  window.__DISABLE_OPTIONAL_SSE = false;
}

import "./agent-status-row.js";
import "./dashboard-broadcast.js";
import "./ops-status-widget.js";
import "./ops-globals-bridge.js";
import "./ops-pill-state.js";

import "./matilda-chat-console.js";
import "./dashboard-delegation.js";

import "./task-events-sse-client.js";
import "./phase22_task_delegation_live_bindings.js";

import "./telemetry/phase65b_metric_bootstrap.js";
