/* Execution Inspector Fix — lightweight adapter layer */

(function () {
  const INSPECTOR_ENDPOINT = "/api/tasks?limit=12";

  function findInspectorCard() {
    return (
      document.getElementById("execution-inspector") ||
      document.querySelector("[data-phase61-panel='inspector']")
    );
  }

  function renderInspector(rows) {
    const card = findInspectorCard();
    if (!card) return;

    const safeRows = Array.isArray(rows) ? rows : [];

    card.innerHTML = safeRows.map(r => {
      const title = r.title || r.task || "(untitled)";
      const status = r.status || "unknown";
      const id = r.task_id || r.id || "—";

      return `
        <div style="border:1px solid rgba(255,255,255,0.08);padding:8px;border-radius:10px;margin-bottom:6px;">
          <div style="font-size:12px;opacity:.85;color:#e5e7eb">${title}</div>
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

      const rows =
        data?.tasks ||
        data?.rows ||
        data?.data ||
        data ||
        [];

      renderInspector(rows);
    } catch (e) {
      console.log("[execution-inspector] fetch error", e);
    }
  }

  setInterval(tick, 5000);
  tick();
})();
