(function () {
  const STREAM_URL = "/events/task-events?cursor=0";
  const ROOT_ID = "mb-task-events-panel-anchor";

  if (window.__TASK_EVENTS_SSE_CLIENT_ACTIVE__) return;
  window.__TASK_EVENTS_SSE_CLIENT_ACTIVE__ = true;

  const events = [];
  const seen = new Set();
  const maxEvents = 80;

  function root() {
    return document.getElementById(ROOT_ID);
  }

  function parse(raw) {
    try { return JSON.parse(raw); } catch { return null; }
  }

  function shortId(v) {
    if (!v) return "—";
    const s = String(v);
    return s.length > 14 ? s.slice(0, 6) + "…" + s.slice(-4) : s;
  }

  function time(v) {
    const d = new Date(Number(v) || v);
    return isNaN(d) ? "" : d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  }

  function getTitle(e) {
    return e.title || e.message || e.payload?.title || e.kind;
  }

  function getRetryInfo(e) {
    const p = e.payload || {};
    if (!p.retry_mode) return "";
    return `retry: ${p.retry_mode}`;
  }

  function badge(kind) {
    if (kind === "task.completed") return "✔";
    if (kind === "task.failed") return "✖";
    if (kind === "task.started") return "▶";
    if (kind === "task.created") return "●";
    return "•";
  }

  function color(kind) {
    if (kind === "task.completed") return "#22c55e";
    if (kind === "task.failed") return "#ef4444";
    if (kind === "task.started") return "#facc15";
    if (kind === "task.created") return "#60a5fa";
    return "#94a3b8";
  }

  function render(state) {
    const el = root();
    if (!el) return;

    const rows = events.map(e => {
      const kind = e.kind || "event";
      const taskId = e.task_id || e.taskId;
      const runId = e.run_id || e.runId;
      const actor = e.actor || "system";

      return `
        <div style="display:flex; flex-direction:column; gap:4px; padding:10px 0; border-bottom:1px solid rgba(255,255,255,.06); font-family:system-ui;">
          
          <div style="display:flex; align-items:center; gap:10px;">
            <div style="color:${color(kind)}; font-weight:600;">
              ${badge(kind)} ${kind.replace("task.","")}
            </div>
            <div style="color:#9ca3af; font-size:12px;">
              ${time(e.ts || e.created_at)}
            </div>
          </div>

          <div style="color:#e5e7eb; font-weight:500;">
            ${getTitle(e)}
          </div>

          <div style="display:flex; gap:12px; flex-wrap:wrap; font-size:12px; color:#a78bfa;">
            <span>task ${shortId(taskId)}</span>
            ${runId ? `<span>run ${shortId(runId)}</span>` : ""}
            ${getRetryInfo(e) ? `<span>${getRetryInfo(e)}</span>` : ""}
          </div>

          <div style="font-size:11px; color:#6b7280;">
            ${actor}
          </div>
        </div>
      `;
    }).join("") || `<div style="color:#94a3b8;">Waiting for events…</div>`;

    el.innerHTML = `
      <div style="display:flex; justify-content:space-between; margin-bottom:8px; font-size:12px; color:#9ca3af;">
        <div>Execution Inspector: ${state}</div>
        <div>${events.length} events</div>
      </div>
      ${rows}
    `;
  }

  function ingest(raw, type) {
    if (type === "hello" || type === "heartbeat") return;

    const e = parse(raw);
    if (!e) return;

    e.kind = e.kind || type;
    const id = e.id || `${e.kind}:${e.task_id}:${e.ts || e.created_at}`;
    if (seen.has(id)) return;

    seen.add(id);
    events.unshift(e);
    if (events.length > maxEvents) events.length = maxEvents;

    render("Connected");
  }

  function start() {
    render("Connecting");

    const es = new EventSource(STREAM_URL);

    es.onopen = () => render("Connected");
    es.onerror = () => render("Connection error");

    es.onmessage = ev => ingest(ev.data, "message");

    ["task.created","task.started","task.completed","task.failed"].forEach(t => {
      es.addEventListener(t, ev => ingest(ev.data, t));
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, { once: true });
  } else {
    start();
  }
})();
