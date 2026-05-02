if (window.__RECENT_HISTORY_WIRE_BOUND) return; window.__RECENT_HISTORY_WIRE_BOUND = true;
/* Execution Inspector — Deterministic Mount + Stable Render Contract */

(function () {

  const INSPECTOR_ID = "execution-inspector";
  const INSPECTOR_ENDPOINT = "/api/tasks?limit=12";
  const REFRESH_MS = 5000;

  /* =========================
     HARD BOOTSTRAP MOUNT
     ========================= */
  function mountInspector() {
    let el = document.getElementById(INSPECTOR_ID);

    if (!el) {
      el = document.createElement("div");
      el.id = INSPECTOR_ID;
      el.setAttribute("data-inspector", "true");

      el.style.padding = "12px";
      el.style.marginTop = "10px";
      el.style.border = "1px solid rgba(255,255,255,0.08)";
      el.style.borderRadius = "12px";
      el.style.background = "rgba(0,0,0,0.35)";
      el.style.color = "#fff";

      document.body.appendChild(el);

      console.log("[execution-inspector] deterministic mount created");
    }

    return el;
  }

  function normalize(data) {
    return data?.tasks || data?.rows || data?.data || [];
  }

  function render(rows) {
    const el = mountInspector();
    if (!el) return;

    if (!rows || !rows.length) {
      el.innerHTML = `
        <div style="opacity:.6;font-size:12px">
          No execution data available
        </div>`;
      return;
    }

    el.innerHTML = rows.map(r => {
      const title = r.title || r.task || "(untitled)";
      const status = r.status || "unknown";
      const id = r.task_id || r.id || "—";

      const outcome = r.outcome_preview || "";
      const explanation = r.explanation_preview || "";

      return `
        <div style="padding:8px;border-bottom:1px solid rgba(255,255,255,0.06)">
          <div style="font-size:12px">${title}</div>
          <div style="font-size:11px;opacity:.6">
            status: ${status} | id: ${id}
          </div>
          ${outcome ? `<div style="margin-top:6px;font-size:11px;color:#d1fae5"><strong>Outcome:</strong> ${outcome}</div>` : ""}
          ${explanation ? `<div style="margin-top:3px;font-size:11px;color:#bfdbfe"><strong>Explanation:</strong> ${explanation}</div>` : ""}
        </div>
      `;
    }).join("");
  }

  async function tick() {
    try {
      const res = await fetch(INSPECTOR_ENDPOINT, { cache: "no-store" });
      const data = await res.json();

      render(normalize(data));

      console.log("[execution-inspector] rendered rows:", normalize(data).length);
    } catch (e) {
      console.log("[execution-inspector] fetch error", e);
    }
  }

  new MutationObserver(() => mountInspector()).observe(document.body, {
    childList: true,
    subtree: true
  });

  mountInspector();
  setInterval(tick, REFRESH_MS);
  tick();

})();
