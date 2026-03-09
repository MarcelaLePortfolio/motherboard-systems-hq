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

  const AGENTS = ["Matilda", "Cade", "Effie", "Atlas"];
  const indicators = {};

  const stack = document.createElement("div");
  stack.className = "w-full flex flex-col gap-0.5";
  container.appendChild(stack);

  AGENTS.forEach((name) => {
    const row = document.createElement("div");
    row.className =
      "w-full min-h-0 rounded-md bg-slate-600/55 border border-slate-500/35 px-3 py-1.5 flex items-center justify-between shadow-sm";

    const left = document.createElement("div");
    left.className = "flex items-center gap-2.5 min-w-0";

    const bar = document.createElement("span");
    bar.className = "block w-1.5 self-stretch rounded-full bg-slate-400/70";

    const label = document.createElement("span");
    label.className = "text-[13px] font-semibold tracking-tight text-slate-100/95 truncate";
    label.textContent = name;

    const status = document.createElement("span");
    status.className = "text-[12px] font-medium text-slate-200/90 truncate";
    status.textContent = "unknown";

    left.append(bar, label);
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
    indicator.bar.className = "block w-1.5 self-stretch rounded-full";
    indicator.label.className = "text-[13px] font-semibold tracking-tight truncate";
    indicator.status.className = "text-[11px] font-medium truncate";

    switch (kind) {
      case "online":
        indicator.row.classList.add("bg-gray-800", "border-gray-700");
        indicator.bar.classList.add("bg-emerald-400");
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-emerald-300/90");
        break;
      case "error":
        indicator.row.classList.add("bg-gray-800", "border-gray-700");
        indicator.bar.classList.add("bg-rose-400");
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-rose-300/90");
        break;
      case "pending":
        indicator.row.classList.add("bg-gray-800", "border-gray-700");
        indicator.bar.classList.add("bg-amber-300");
        indicator.label.classList.add("text-slate-100");
        indicator.status.classList.add("text-amber-200/90");
        break;
      case "unknown":
      default:
        indicator.row.classList.add("bg-gray-800", "border-gray-700");
        indicator.bar.classList.add("bg-slate-400/70");
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

  let source;
  try {
    source = (window.__PHASE16_SSE_OWNER_STARTED ? null : new EventSource(OPS_SSE_URL));
  } catch (err) {
    console.error("agent-status-row.js: Failed to open OPS SSE connection:", err);
    return;
  }

  if (!source) return;

  source.onmessage = (event) => {
    let data;
    try {
      data = JSON.parse(event.data);
    } catch {
      return;
    }

    const agentName =
      (data.agent || data.actor || data.source || data.worker || "").toString().toLowerCase();
    if (!agentName || !indicators[agentName]) return;

    const status = (data.status || data.state || data.level || "").toString() || "unknown";
    applyVisual(agentName, status);
  };

  source.onerror = (err) => {
    console.warn("agent-status-row.js: OPS SSE error:", err);
    Object.keys(indicators).forEach((key) => applyVisual(key, "unknown"));
  };
})();
