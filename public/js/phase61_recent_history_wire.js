/* Execution Inspector — Isolation Layer (protect from dashboard DOM writers) */
(function () {

  const INSPECTOR_ID = "execution-inspector";
  const INSPECTOR_ENDPOINT = "/api/tasks?limit=12";
  const REFRESH_MS = 5000;

  function ensureInspector() {
    let el = document.getElementById(INSPECTOR_ID);

    // If missing OR moved under a dashboard-controlled container, reattach to body
    if (!el || el.parentElement !== document.body) {
      el = document.createElement("div");
      el.id = INSPECTOR_ID;
      el.setAttribute("data-inspector-isolated", "true");

      el.style.position = "relative";
      el.style.zIndex = "9999";
      el.style.padding = "12px";
      el.style.marginTop = "10px";
      el.style.border = "1px solid rgba(255,255,255,0.08)";
      el.style.borderRadius = "12px";
      el.style.background = "rgba(0,0,0,0.35)";

      document.body.appendChild(el);

      console.log("[execution-inspector][isolation] mounted/re-attached to body");
    }

    return el;
  }

  function normalizeRows(data) {
    return (data?.tasks || data?.rows || data?.data || []);
  }

  function render(rows) {
    const el = ensureInspector();
    if (!el) return;

    if (!rows.length) {
      el.innerHTML = `
        <div style="opacity:.6;font-size:12px;padding:10px;">
          No execution data available
        </div>`;
      return;
    }

    el.innerHTML = rows.map(r => {
      const title = r.title || r.task || "(untitled)";
      const status = r.status || "unknown";
      const id = r.task_id || r.id || "—";

      return `
        <div style="padding:8px;border-bottom:1px solid rgba(255,255,255,0.06)">
          <div style="font-size:12px;color:#fff">${title}</div>
          <div style="font-size:11px;opacity:.6">
            status: ${status} | id: ${id}
          </div>
        </div>
      `;
    }).join("");
  }

  async function tick() {
    try {
      const res = await fetch(INSPECTOR_ENDPOINT, { cache: "no-store" });
      const data = await res.json();

      const rows = normalizeRows(data);
      render(rows);

      console.log("[execution-inspector] rendered rows:", rows.length);
    } catch (e) {
      console.log("[execution-inspector] fetch error", e);
    }
  }

  // HARD ISOLATION GUARD: continuously enforce ownership
  const observer = new MutationObserver(() => {
    ensureInspector();
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true
  });

  setInterval(tick, REFRESH_MS);
  tick();

})();
