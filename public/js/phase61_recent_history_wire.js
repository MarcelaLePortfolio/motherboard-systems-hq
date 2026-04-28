/* UNIFIED INSPECTOR ARCHITECTURE — SINGLE SOURCE OF TRUTH
   Phase Fix: eliminate dual renderers + DOM races + bridge conflict */

(function () {
  const INSPECTOR_ENDPOINT = "/api/tasks?limit=12";
  const REFRESH_MS = 5000;

  function log() {
    try {
      console.log("[execution-inspector]", ...arguments);
    } catch (_) {}
  }

  function findInspector() {
    return document.querySelector('[data-phase61-panel="inspector"]') || document.getElementById("execution-inspector");
  }

  function normalizeRows(data) {
    if (!data) return [];
    if (Array.isArray(data.tasks)) return data.tasks;
    if (Array.isArray(data.rows)) return data.rows;
    if (Array.isArray(data.data)) return data.data;
    if (Array.isArray(data)) return data;
    return [];
  }

  function render(rows) {
    const el = findInspector();
    if (!el) return;

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

  // SINGLE LOOP ONLY (no bridge, no fallback, no duplication)
  setInterval(tick, REFRESH_MS);
  tick();
})();
