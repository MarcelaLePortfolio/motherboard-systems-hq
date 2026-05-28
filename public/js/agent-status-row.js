(() => {
  "use strict";

  const container = document.getElementById("agent-status-container");
  if (!container) {
    console.warn("agent-status-row.js: #agent-status-container not found.");
    return;
  }

  const AGENTS = ["Matilda", "Atlas", "Cade", "Effie"];

  const AGENT_EMOJI = {
    Matilda: "🗣️",
    Atlas: "🧭",
    Cade: "💻",
    Effie: "📊"
  };

  function normalizeStatus(value) {
    return String(value || "unknown").trim().toLowerCase();
  }

  function statusClass(status) {
    const s = normalizeStatus(status);
    if (s === "online" || s === "active" || s === "running") return "text-emerald-300/90";
    if (s === "offline" || s === "stopped") return "text-slate-300/75";
    if (s === "error" || s === "failed") return "text-rose-300/90";
    return "text-amber-200/90";
  }

  function render(data = {}) {
    const agents = Object.keys(data || {});
    const healthy = agents.length > 0;

    window.__AGENT_POOL_HEALTH = healthy;
    window.__AGENT_POOL_LAST_CHECK = Date.now();

    const time = new Date().toLocaleTimeString();

    const healthDot = healthy
      ? `<span title="Live • Last check: ${time}" style="margin-left:8px;color:#34d399;font-size:12px;">●</span>`
      : `<span title="No data • Last check: ${time}" style="margin-left:8px;color:#f87171;font-size:12px;">○</span>`;

    const rows = AGENTS.map((name) => {
      const raw = data[name] || {};
      const status = typeof raw === "string" ? raw : raw.status || "unknown";

      return `
        <div class="w-full min-h-0 rounded-md bg-gray-900 border border-gray-700 px-3 py-1.5 flex items-center justify-between shadow-sm">
          <div class="flex items-center gap-3 min-w-0 h-[18px]">
            <span style="width:18px;min-width:18px;height:18px;font-size:14px;">${AGENT_EMOJI[name] || "•"}</span>
            <span class="text-[13px] font-semibold text-slate-100 truncate">${name}</span>
          </div>
          <span class="text-[11px] font-medium ${statusClass(status)}">${status}</span>
        </div>
      `;
    }).join("");

    container.innerHTML = `
      <h2 class="text-xl font-semibold border-b border-gray-700 pb-2 mb-4">
        Agent Pool ${healthDot}
      </h2>
      <div class="w-full flex flex-col gap-1">
        ${rows}
      </div>
    `;
  }

  async function refresh() {
    try {
      const res = await fetch("/api/agent-status", { cache: "no-store" });
      const data = await res.json();
      render(data);
    } catch (err) {
      console.warn("agent-status-row.js: failed to fetch /api/agent-status", err);
      render({});
    }
  }

  render({});
  refresh();
  window.setInterval(refresh, 15000);

  window.addEventListener("mb.agent.status", (e) => {
    if (!e?.detail) return;
    render(e.detail);
  });

  window.__AGENT_POOL_RENDERER_LOCKED = true;

  console.log("[agent-status-row] live health indicator with timestamp active");
})();
