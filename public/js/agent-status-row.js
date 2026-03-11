// Phase 60 — Agent Pool compact console rows
// Cosmetic renderer only.
// Keeps the existing OPS SSE behavior, but restores the intended
// dense operator-console row appearance.

(() => {
  const container = document.getElementById("agent-status-container");
  if (!container) {
    console.warn("agent-status-row.js: #agent-status-container not found.");
    return;
  }

  const title = container.querySelector("h2");
  container.innerHTML = "";
  if (title) container.appendChild(title);

  const AGENTS = ["Matilda","Atlas","Cade","Effie"];

const AGENT_EMOJI = {
matilda:"🗣️",
atlas:"🧭",
cade:"💻",
effie:"📊"
};
  const indicators = {};

  const stack = document.createElement("div");
  stack.className = "w-full flex flex-col gap-0.5";
  container.appendChild(stack);

  AGENTS.forEach((name) => {
    const row = document.createElement("div");
    row.className =
      "w-full min-h-0 rounded-md bg-slate-600/55 border border-slate-500/35 px-3 py-1.5 flex items-center justify-between shadow-sm";

    const left = document.createElement("div");
    left.className = "flex items-center gap-3 min-w-0 h-[18px]";

    const icon = document.createElement("span");
icon.textContent = AGENT_EMOJI[key] || "•";
icon.style.minWidth="18px";
icon.style.fontSize="14px";

left.append(icon,label);
    row.append(left, status);
    stack.appendChild(row);

    indicators[name.toLowerCase()] = { row, bar, label, status };
  });

  const OPS_SSE_URL = `/events/ops`;
  const __DISABLE_OPTIONAL_SSE =
    (typeof window !== "undefined" && window.__DISABLE_OPTIONAL_SSE) === true;

  function classifyStatus(statusString) {
    if (
      typeof window !== "undefined" &&
      window.__PHASE16_SSE_OWNER_STARTED
    ) {
      return "unknown";
    }

    const s = (statusString || "").toLowerCase();
    if (!s) return "unknown";
    if (s.includes("error") || s.includes("failed") || s.includes("offline")) return "error";
    if (s.includes("online") || s.includes("ready") || s.includes("ok")) return "online";
    if (s.includes("queued") || s.includes("pending") || s.includes("init") || s.includes("running")) return "pending";
    return "unknown";
  }

  function applyVisual(agentKey, statusString) {
    const indicator = indicators[agentKey];
    if (!indicator) return;

    const kind = classifyStatus(statusString);
    const finalStatus = statusString || "unknown";
    indicator.status.textContent = finalStatus;

    indicator.row.className =
      "w-full min-h-0 rounded-md border px-3 py-1.5 flex items-center justify-between shadow-sm";
    

    indicator.bar.style.boxShadow = "0 0 0 2px rgba(255,255,255,0.08) inset";
    indicator.bar.style.background = "rgba(148,163,184,0.8)";
indicator.bar.style.width = "8px";
indicator.bar.style.height = "8px";
indicator.bar.style.minWidth = "8px";
indicator.bar.style.minHeight = "8px";
indicator.bar.style.borderRadius = "999px";
indicator.bar.style.marginRight = "8px";

    indicator.label.className = "text-[13px] font-semibold tracking-tight truncate";
    indicator.status.className = "text-[11px] font-medium truncate";

    switch (kind) {
      case "online":
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.bar.style.background = "rgba(52,211,153,0.95)";
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-emerald-300/90");
        break;
      case "error":
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.bar.style.background = "rgba(251,113,133,0.95)";
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-rose-300/90");
        break;
      case "pending":
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.bar.style.background = "rgba(252,211,77,0.95)";
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-amber-200/90");
        break;
      case "unknown":
      default:
        indicator.row.classList.add("bg-gray-900", "border-gray-700");
        indicator.bar.style.background = "rgba(148,163,184,0.8)";
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-slate-300/75");
        break;
    }
  }

  Object.keys(indicators).forEach((key) => applyVisual(key, "unknown"));

  if (__DISABLE_OPTIONAL_SSE) {
    console.warn("[agent-status-row] Optional SSE disabled:", OPS_SSE_URL);
    return;
  }

  function parseJson(raw) {
    try {
      return JSON.parse(raw);
    } catch {
      return null;
    }
  }

  function extractPayload(data) {
    if (!data || typeof data !== "object") return null;
    if (data.payload && typeof data.payload === "object") return data.payload;
    if (data.data && typeof data.data === "object") return data.data;
    if (data.state && typeof data.state === "object") return data.state;
    return data;
  }

  function applyAgentMap(payload) {
    if (!payload || typeof payload !== "object") return false;
    const agents = payload.agents;
    if (!agents || typeof agents !== "object") return false;

    let applied = false;
    for (const [name, value] of Object.entries(agents)) {
      const key = String(name || "").toLowerCase();
      if (!indicators[key]) continue;

      let status = "unknown";
      if (typeof value === "string") {
        status = value;
      } else if (value && typeof value === "object") {
        status =
          value.status ??
          value.state ??
          value.level ??
          value.health ??
          value.mode ??
          "unknown";
      }

      applyVisual(key, String(status || "unknown"));
      applied = true;
    }
    return applied;
  }

  function applySingleAgent(data) {
    if (!data || typeof data !== "object") return false;

    const agentName =
      (data.agent || data.actor || data.source || data.worker || data.name || "").toString().toLowerCase();
    if (!agentName || !indicators[agentName]) return false;

    const status =
      data.status ??
      data.state ??
      data.level ??
      data.health ??
      data.mode ??
      "unknown";

    applyVisual(agentName, String(status || "unknown"));
    return true;
  }

  function handleOpsEvent(eventName, event) {
    const data = parseJson(event.data);
    if (!data) return;

    const payload = extractPayload(data);

    if (eventName === "ops.state") {
      if (applyAgentMap(payload)) return;
    }

    if (applyAgentMap(data)) return;
    if (applyAgentMap(payload)) return;
    applySingleAgent(payload);
    applySingleAgent(data);
  }

  let source;
  try {
    source = (window.__PHASE16_SSE_OWNER_STARTED ? null : new EventSource(OPS_SSE_URL));
  } catch (err) {
    console.error("agent-status-row.js: Failed to open OPS SSE connection:", err);
    return;
  }

  if (!source) return;

  source.onmessage = (event) => handleOpsEvent("message", event);
  source.addEventListener("hello", (event) => handleOpsEvent("hello", event));
  source.addEventListener("ops.state", (event) => handleOpsEvent("ops.state", event));
  source.addEventListener("state", (event) => handleOpsEvent("state", event));
  source.addEventListener("update", (event) => handleOpsEvent("update", event));

  source.onerror = (err) => {
    console.warn("agent-status-row.js: OPS SSE error:", err);
    Object.keys(indicators).forEach((key) => applyVisual(key, "unknown"));
  };
})();
