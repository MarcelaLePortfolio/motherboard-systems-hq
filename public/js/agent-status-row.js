// <0001fb02> Agent Status Row – live heartbeats from OPS SSE
// - Renders status pills for Matilda, Cade, Effie, Atlas
// - Listens to OPS SSE on port 3201
// - Updates colors/text based on incoming status

(() => {
  const container = document.getElementById("agent-status-container");
  if (!container) {
    console.warn("agent-status-row.js: #agent-status-container not found.");
    return;
  }

  // Clear placeholder text (e.g., "Loading agents...")
  container.innerHTML = "";

  const AGENTS = ["Matilda", "Cade", "Effie", "Atlas"];
  const indicators = {};

  const row = document.createElement("div");
  row.className = "flex flex-wrap gap-4 items-center";
  container.appendChild(row);

  AGENTS.forEach((name) => {
    const pill = document.createElement("div");
    pill.className =
      "px-3 py-1 rounded-full bg-gray-700 text-sm flex items-center gap-2 shadow";

    const dot = document.createElement("span");
    dot.className = "w-2 h-2 rounded-full bg-yellow-400";

    const label = document.createElement("span");
    label.textContent = `${name}: ⏳`;

    pill.dataset.agent = name.toLowerCase();
    pill.append(dot, label);
    row.appendChild(pill);

    indicators[name.toLowerCase()] = { pill, dot, label };
  });

  const OPS_SSE_URL = `/events/ops`;
  

  const __DISABLE_OPTIONAL_SSE = (typeof window !== "undefined" && window.__DISABLE_OPTIONAL_SSE) === true;
  if (__DISABLE_OPTIONAL_SSE) {
    console.warn("[agent-status-row] Optional SSE disabled (Phase 16 pending):", OPS_SSE_URL);
    Object.keys(indicators).forEach((key) => applyVisual(key, "unknown"));
    return;
  }
let source;

  try {
    source = new EventSource(OPS_SSE_URL);
  } catch (err) {
    console.error("agent-status-row.js: Failed to open OPS SSE connection:", err);
    return;
  }

  function classifyStatus(statusString) {
    const s = (statusString || "").toLowerCase();
    if (!s) return "unknown";
    if (s.includes("error") || s.includes("failed") || s.includes("offline")) {
      return "error";
    }
    if (s.includes("online") || s.includes("ready") || s.includes("ok")) {
      return "online";
    }
    if (s.includes("queued") || s.includes("pending") || s.includes("init")) {
      return "pending";
    }
    return "unknown";
  }

  function applyVisual(agentKey, statusString) {
    const indicator = indicators[agentKey];
    if (!indicator) return;

    const kind = classifyStatus(statusString);
    const { pill, dot, label } = indicator;

    // Reset base classes
    dot.className = "w-2 h-2 rounded-full";
    pill.classList.remove("border", "border-red-400", "border-green-400", "border-yellow-300");

    switch (kind) {
      case "online":
        dot.classList.add("bg-green-400");
        pill.classList.add("border", "border-green-400");
        break;
      case "error":
        dot.classList.add("bg-red-400");
        pill.classList.add("border", "border-red-400");
        break;
      case "pending":
        dot.classList.add("bg-yellow-300");
        pill.classList.add("border", "border-yellow-300");
        break;
      case "unknown":
      default:
        dot.classList.add("bg-gray-500");
        break;
    }

    const prettyName = agentKey.charAt(0).toUpperCase() + agentKey.slice(1);
    const finalStatus = statusString || "unknown";
    label.textContent = `${prettyName}: ${finalStatus}`;
  }

  source.onmessage = (event) => {
    let payloadRaw = event.data;
    let data;

    try {
      data = JSON.parse(payloadRaw);
    } catch {
      // If it's not JSON, ignore for agent-status purposes
      return;
    }

    const agentName =
      (data.agent || data.actor || data.source || data.worker || "").toString();
    if (!agentName) return;

    const key = agentName.toLowerCase();
    if (!indicators[key]) {
      // Ignore agents we don't show in the row
      return;
    }

    const status = (data.status || data.state || data.level || "").toString() || "unknown";
    applyVisual(key, status);
  };

  source.onerror = (err) => {
    console.warn("agent-status-row.js: OPS SSE error:", err);
    // On error, show all as unknown (neutral gray)
    Object.keys(indicators).forEach((key) => applyVisual(key, "unknown"));
  };
})();
