// <0001fb01> Dashboard Status – OPS + Reflections SSE wiring
// - Connects to Python OPS SSE (port 3201) and Reflections SSE (port 3200)
// - Updates uptime, health, metrics, ops alerts, and reflections panel

export function initDashboardStatus() {
  console.log("[dashboard-status] initDashboardStatus() running");
  if (typeof window === "undefined" || typeof document === "undefined") return;
  if (window.__dashboardStatusInited) return;
  window.__dashboardStatusInited = true;

  const OPS_SSE_URL = `/events/ops`;
  const REFLECTIONS_SSE_URL = `/events/reflections`;

  // Core elements
  const uptimeDisplay = document.getElementById("uptime-display");
  const healthIndicator = document.getElementById("system-health-indicator");
  const healthStatus = document.getElementById("health-status");

  const metricAgents = document.getElementById("metric-agents");
  const metricTasks = document.getElementById("metric-tasks");
  const metricSuccessRate = document.getElementById("metric-success-rate");
  const metricLatency = document.getElementById("metric-latency");

  const reflectionsContainer = document.getElementById("recentLogs");
  const opsAlertsList = document.getElementById("ops-alerts-list");

  const pageStart = Date.now();
  const agentStatusMap = {}; // agentName -> lastStatus

  let totalOpsEvents = 0;
  let successfulOpsEvents = 0;
  let errorOpsEvents = 0;

  // --- 1) Uptime updater ---
  function formatDuration(seconds) {
    const s = seconds % 60;
    const m = Math.floor(seconds / 60) % 60;
    const h = Math.floor(seconds / 3600);
    if (h > 0) return `${h}h ${m}m ${s}s`;
    if (m > 0) return `${m}m ${s}s`;
    return `${s}s`;
  }

  function tickUptime() {
    if (!uptimeDisplay) return;
    const diffSec = Math.floor((Date.now() - pageStart) / 1000);
    uptimeDisplay.textContent = formatDuration(diffSec);
  }

  tickUptime();
  setInterval(tickUptime, 1000);

  // --- 2) Health classification helpers ---
  function classifyHealthFromStatus(statusString) {
    const s = (statusString || "").toLowerCase();
    if (!s) return "degraded";

    if (s.includes("error") || s.includes("failed") || s.includes("critical")) {
      return "critical";
    }
    if (s.includes("warn") || s.includes("degraded")) {
      return "degraded";
    }
    if (s.includes("ok") || s.includes("online") || s.includes("ready") || s.includes("healthy")) {
      return "healthy";
    }
    return "degraded";
  }

  function applyHealthVisual(healthState) {
    if (!healthIndicator || !healthStatus) return;

    healthIndicator.classList.remove("bg-red-500", "bg-yellow-400", "bg-green-400");
    healthIndicator.classList.remove("animate-pulse");

    switch (healthState) {
      case "healthy":
        healthIndicator.classList.add("bg-green-400");
        healthStatus.textContent = "Stable";
        break;
      case "critical":
        healthIndicator.classList.add("bg-red-500", "animate-pulse");
        healthStatus.textContent = "Critical";
        break;
      case "degraded":
      default:
        healthIndicator.classList.add("bg-yellow-400");
        healthStatus.textContent = "Degraded";
        break;
    }
  }

  // Initialize health view
  applyHealthVisual("degraded");

  // --- 3) OPS SSE: metrics + alerts ---
  let opsSource;
  try {
    opsSource = new EventSource(OPS_SSE_URL);
  } catch (err) {
    console.error("dashboard-status.js: Failed to open OPS SSE connection:", err);
    return;
  }

  opsSource.onmessage = (event) => {
    let payloadRaw = event.data;
    let data = null;

    try {
      data = JSON.parse(payloadRaw);
    } catch {
      data = { message: payloadRaw };
    }

    totalOpsEvents++;

    const agentName =
      (data.agent || data.actor || data.source || data.worker || "").toString();
    const statusString =
      (data.status || data.state || data.level || "").toString();
    const message =
      data.message ||
      data.event ||
      data.description ||
      data.type ||
      payloadRaw;

    if (agentName) {
      agentStatusMap[agentName] = statusString || "unknown";
    }

    // Active agents metric
    if (metricAgents) {
      const uniqueAgents = Object.keys(agentStatusMap).length;
      metricAgents.textContent = String(uniqueAgents || "--");
    }

    // Tasks metric (approx: count of OPS events)
    if (metricTasks) {
      metricTasks.textContent = String(totalOpsEvents);
    }

    // Latency metric (if present)
    if (metricLatency && typeof data.latency_ms === "number") {
      metricLatency.textContent = String(Math.round(data.latency_ms));
    }

    // Success rate metric
    const statusLower = statusString.toLowerCase();
    if (statusLower.includes("success") || statusLower.includes("completed") || statusLower.includes("ok")) {
      successfulOpsEvents++;
    } else if (statusLower.includes("error") || statusLower.includes("failed")) {
      errorOpsEvents++;
    }

    if (metricSuccessRate) {
      const denom = successfulOpsEvents + errorOpsEvents;
      if (denom > 0) {
        const pct = Math.round((successfulOpsEvents / denom) * 100);
        metricSuccessRate.textContent = `${pct}%`;
      } else {
        metricSuccessRate.textContent = "--";
      }
    }

    // Health from status
    const healthState = classifyHealthFromStatus(statusString);
    applyHealthVisual(healthState);

    // Ops alerts list
    if (opsAlertsList) {
      const li = document.createElement("li");
      li.className = "text-sm";

      const now = new Date();
      const ts = now.toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
      });

      const safeAgent = agentName || "System";
      const labelParts = [`[${ts}]`, safeAgent];

      if (statusString) labelParts.push(`– ${statusString}`);
      if (message && message !== statusString) {
        labelParts.push(`– ${String(message).slice(0, 160)}`);
      }

      li.textContent = labelParts.join(" ");
      opsAlertsList.prepend(li);

      // keep list from growing unbounded
      while (opsAlertsList.children.length > 50) {
        opsAlertsList.removeChild(opsAlertsList.lastChild);
      }
    }
  };

  opsSource.onerror = (err) => {
    console.warn("dashboard-status.js: OPS SSE error:", err);
    applyHealthVisual("degraded");

    if (opsAlertsList) {
      const li = document.createElement("li");
      li.className = "text-sm text-red-400";
      li.textContent = "[OPS] SSE connection error – attempting to recover…";
      opsAlertsList.prepend(li);

      while (opsAlertsList.children.length > 50) {
        opsAlertsList.removeChild(opsAlertsList.lastChild);
      }
    }
  };

  // --- 4) Reflections SSE: #recentLogs ---
  let reflectionsSource;
  try {
    console.log("[dashboard-status] opening Reflections SSE:", REFLECTIONS_SSE_URL);
    reflectionsSource = new EventSource(REFLECTIONS_SSE_URL);
  } catch (err) {
    console.error("dashboard-status.js: Failed to open Reflections SSE connection:", err);
    return;
  }

  reflectionsSource.onmessage = (event) => {
      console.log("[dashboard-status] reflections onmessage:", event.data);
    if (!reflectionsContainer) return;

    const raw = event.data;
    let text = raw;

    try {
      const parsed = JSON.parse(raw);
      text =
        parsed.message ||
        parsed.reflection ||
        parsed.text ||
        parsed.log ||
        raw;
    } catch {
      // plain text is fine
    }

    const entry = document.createElement("div");
    entry.className =
      "text-sm text-gray-200 border-b border-gray-700 pb-2 mb-2 whitespace-pre-line";
    entry.textContent = text;

    reflectionsContainer.prepend(entry);

    // keep reflections list bounded
    while (reflectionsContainer.children.length > 50) {
      reflectionsContainer.removeChild(reflectionsContainer.lastChild);
    }
  };

  reflectionsSource.onerror = (err) => {
    console.warn("dashboard-status.js: Reflections SSE error:", err);
    if (!reflectionsContainer) return;

    const entry = document.createElement("div");
    entry.className = "text-xs text-red-400 italic";
    entry.textContent =
      "[Reflections] SSE connection error – check Python reflections_stream on port 3200.";
    reflectionsContainer.prepend(entry);

    while (reflectionsContainer.children.length > 50) {
      reflectionsContainer.removeChild(reflectionsContainer.lastChild);
    }
  };
}

if (typeof window !== "undefined") {
  window.initDashboardStatus = initDashboardStatus;

// Auto-init when loaded via bundle entry
if (typeof window !== "undefined" && typeof document !== "undefined") {
  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", () => initDashboardStatus());
  } else {
    initDashboardStatus();
  }
}
}
