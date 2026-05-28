
import "./sse-heartbeat-shim.js";

import "./heartbeat-stale-indicator.js";

// Phase 11 – Unified dashboard bundle entrypoint

// Core dashboard status + tiles

import "./dashboard-status.js";

// Phase 15/16 boundary: optional SSE remains enabled because runtime SSE is restored.

if (typeof window !== "undefined" && typeof window.__DISABLE_OPTIONAL_SSE === "undefined") {

  window.__DISABLE_OPTIONAL_SSE = false;

}

import "./agent-status-row.js";

// OPS / PM2 status + SSE wiring

import "./dashboard-broadcast.js";

import "./ops-status-widget.js";

import "./ops-globals-bridge.js";

import "./ops-pill-state.js";

// Dashboard UI restore: Recent Tasks widget restored after runtime reset.

// This is UI/read-path only and does not grant execution authority.

import "./dashboard-tasks-widget.js";

// Matilda chat console wiring

import "./matilda-chat-console.js";

import "./dashboard-delegation.js";

// Task-events live UI

import "./task-events-sse-client.js";

import "./phase22_task_delegation_live_bindings.js";

// Telemetry metric ownership bootstrap

import "./telemetry/phase65b_metric_bootstrap.js";

