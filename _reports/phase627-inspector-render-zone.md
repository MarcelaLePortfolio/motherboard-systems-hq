# Phase 627 Inspector Render Zone

## public/js/phase61_recent_history_wire.js
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

## public/js/task-events-sse-client.js inspector area
    const rows = events.map((e, i) => {
      const kind = e.kind || "task.event";
      const taskId = e.task_id || e.taskId || "";
      const runId = e.run_id || e.runId || "";
      const ts = e.created_at || e.ts || Date.now();
      const title = resolveTitle(e);
      const json = JSON.stringify(e, null, 2);

      return `
<details data-idx="${i}" style="border-top:1px solid rgba(148,163,184,.2); padding:16px 0;">
  <summary style="list-style:none; cursor:pointer; display:grid; grid-template-columns:120px 1fr; gap:16px; padding-left:12px;">
    <div>
      <div style="color:${kind === "task.completed" ? "#86efac" : "#93c5fd"}; font-weight:700;">
        ${kind.replace("task.", "")}
      </div>
      <div style="color:#64748b; font-size:12px;">${formatTime(ts)}</div>
    </div>

    <div>
      <div style="font-weight:700;">${escapeHtml(title)}</div>
      <div style="margin-top:8px; display:flex; gap:16px;">
        <span data-action="copy-id" style="color:#86efac; cursor:pointer;">Copy ID</span>
        <span data-action="requeue" style="color:#facc15; cursor:pointer;">Requeue</span>
        <span data-action="retry" style="color:#60a5fa; cursor:pointer;">Retry</span>
      </div>
    </div>
  </summary>

  <div style="width:92%; margin:14px auto 0 auto; background:#111827; border:1px solid #334155; border-radius:12px; padding:16px;">
    <div>${escapeHtml(contextText(e))}</div>

    <div style="margin-top:8px; color:#a78bfa; font-family:monospace;">
      task=${escapeHtml(shortId(taskId))} ${runId ? "• run=" + escapeHtml(shortId(runId)) : ""}
    </div>

    <details style="margin-top:10px;">
      <summary style="cursor:pointer;">Advanced ▸</summary>
      <pre style="margin-top:8px; font-size:11px;">${escapeHtml(json)}</pre>
    </details>
  </div>
</details>
      `;
    }).join("");

    el.innerHTML = `
      <div style="display:flex; justify-content:space-between; margin-bottom:12px;">
        <span>Execution Inspector: ${escapeHtml(state)}</span>
        <span>${events.length} events</span>
      </div>
      ${rows}
    `;

    document.querySelectorAll("details[data-idx]").forEach((node) => {
      const idx = Number(node.getAttribute("data-idx"));
      wireActions(node, events[idx]);
    });
  }

  function ingest(raw, type) {
    if (type === "hello" || type === "heartbeat") return;

    const e = parse(raw);
    if (!e) return;

    e.kind = e.kind || type;

    const taskId = e.task_id || e.taskId;
    if (!taskId) return;

    const id = e.id || `${e.kind}:${taskId}`;
    if (seen.has(id)) return;
