/* Execution Inspector Fix — unified renderer (Option 1 canonical DOM root) */
(function () {

  const INSPECTOR_ENDPOINT = "/api/tasks?limit=12";
  const REFRESH_MS = 5000;

  function log() {
    console.log("[execution-inspector]", ...arguments);
  }

  function normalizeRows(data) {
    return (data?.tasks || data?.rows || data?.data || []);
  }

  function render(rows) {
    const el = document.getElementById("execution-inspector");
    if (!el) {
      console.warn("[execution-inspector] mount not found");
      return;
    }

    if (!rows.length) {
      el.innerHTML = `
        <div style="padding:10px;opacity:.6;font-size:12px">
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

      log("rendered rows:", rows.length);
    } catch (e) {
      console.log("[execution-inspector] fetch error", e);
    }
  }

  setInterval(tick, REFRESH_MS);
  tick();

})();
