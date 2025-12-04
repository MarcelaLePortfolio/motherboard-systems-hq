
Phase 11 – STEP 3B Broadcast Visualization Status
1. Current Status

As of this commit:

public/js/dashboard-graph-loader.js now exposes:

export function initTaskGraphFromTasks()

Guard: window.__taskGraphFromTasksInited

DOMContentLoaded-aware wiring so it only runs once.

public/js/dashboard-broadcast.js now exposes:

export function initBroadcastVisualization()

Guard key: window.__broadcastVisualizationInited

DOMContentLoaded-aware wiring so it only runs once.

public/js/dashboard-bundle-entry.js orchestrates:

import "./dashboard-status.js";
import { initTaskGraphFromTasks } from "./dashboard-graph-loader.js";
import { initBroadcastVisualization } from "./dashboard-broadcast.js";
import "./dashboard-graph.js";
import "../scripts/dashboard-reflections.js";
import "../scripts/dashboard-ops.js";
import "../scripts/dashboard-chat.js";
import "./matilda-chat-console.js";
import "./task-delegation.js";

try {
  initTaskGraphFromTasks();
} catch (err) {
  console.error("Failed to initialize task graph loader from bundle entry:", err);
}

try {
  initBroadcastVisualization();
} catch (err) {
  console.error("Failed to initialize broadcast visualization from bundle entry:", err);
}


npm run build:dashboard-bundle is succeeding.

Dashboard renders with:

Cards and tiles visible.

Matilda chat card and task delegation controls visible.

Expected SSE connection warnings in console (backends not running), but no bundling errors.

2. What STEP 3B Has Achieved So Far

Moved task graph loader and broadcast visualization away from top-level side effects.

Introduced guarded init functions to avoid:

Duplicate event listeners.

Duplicate intervals.

Re-running the same logic on reloads.

Centralized initialization for these modules in the bundle entrypoint.

This keeps behavior deterministic and prepares the dashboard for further bundling work.

3. Next Recommended STEP 3B Target

The next low-risk but important module to wrap is:

public/js/dashboard-status.js

Suggested shape:

Add:

export function initDashboardStatus() {
  if (typeof window === "undefined" || typeof document === "undefined") return;
  if (window.__dashboardStatusInited) return;
  window.__dashboardStatusInited = true;

  // existing uptime, health, metrics, and SSE wiring logic goes here
}


Replace top-level code with the contents of initDashboardStatus().

Optionally expose for debugging:

if (typeof window !== "undefined") {
  window.initDashboardStatus = initDashboardStatus;
}


Wire from public/js/dashboard-bundle-entry.js:

import { initDashboardStatus } from "./dashboard-status.js";

try {
  initDashboardStatus();
} catch (err) {
  console.error("Failed to initialize dashboard status from bundle entry:", err);
}


Keep init order sensible:

Status early (so health/metrics are ready).

Graphs and broadcast visualization after.

After each change:

Run: npm run build:dashboard-bundle

Reload dashboard and verify:

No duplicate visual behavior.

No new JS errors.

Core cards still render.

4. Golden Rules (Phase 11)

Small refactors, small commits.

Max 3 failed attempts per approach → then revert to last stable commit and rethink.

No DB or schema work in Phase 11:

All DB work remains deferred to:

Phase 11.5 – DB Task Storage

5. Handoff Phrase for Future Threads

To resume from this exact state in a new ChatGPT thread, say:

Continue Phase 11 STEP 3B bundling from PHASE11_BUNDLING_STEP3B_BROADCAST_STATUS.md.

This implies:

Task graph and broadcast visualizations are both guarded and orchestrated via the bundle entry.

npm run build:dashboard-bundle is currently succeeding.

The next logical STEP 3B move is a guarded init for dashboard-status.js (or another clearly scoped module), followed by incremental verification.
