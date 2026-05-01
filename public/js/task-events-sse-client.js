(function () {
  const STREAM_URL = "/events/task-events?cursor=0";
  const ROOT_ID = "mb-task-events-panel-anchor";

  if (window.__TASK_EVENTS_SSE_CLIENT_ACTIVE__) return;
  window.__TASK_EVENTS_SSE_CLIENT_ACTIVE__ = true;

  const events = [];
  const seen = new Set();
  const titlesByTaskId = new Map();
  const maxEvents = 80;

  function root() {
    return document.getElementById(ROOT_ID);
  }

  function escapeHtml(v) {
    return String(v ?? "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function parse(raw) {
    try { return JSON.parse(raw); } catch { return null; }
  }

  function payload(e) {
    return e && e.payload && typeof e.payload === "object" ? e.payload : {};
  }

  function value(e, key) {
    const p = payload(e);
    return e?.[key] ?? p?.[key] ?? "";
  }

  function shortId(v) {
    const s = String(v || "");
    return s.length > 18 ? s.slice(0, 10) + "…" + s.slice(-6) : s;
  }

  function formatTime(v) {
    const d = new Date(Number(v) || v);
    return Number.isNaN(d.getTime())
      ? String(v || "")
      : d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" });
  }

  function resolveTitle(e) {
    const taskId = e.task_id || e.taskId || "";
    const p = payload(e);

    const t =
      e.title ||
      p.title ||
      e.message ||
      p.message ||
      e.detail ||
      p.detail ||
      "";

    if (t && !String(t).startsWith("{")) {
      titlesByTaskId.set(taskId, t);
      return t;
    }

    return titlesByTaskId.get(taskId) || "Untitled task";
  }

  function status(kind) {
    if (kind === "task.completed") return "completed";
    if (kind === "task.created") return "created";
    if (kind === "task.failed") return "failed";
    if (kind === "task.started") return "started";
    return "event";
  }

  function color(kind) {
    if (kind === "task.completed") return "#86efac";
    if (kind === "task.created") return "#93c5fd";
    if (kind === "task.failed") return "#f87171";
    if (kind === "task.started") return "#facc15";
    return "#cbd5e1";
  }

  function render(state) {
    const el = root();
    if (!el) return;

    const rows = events.map((e) => {
      const kind = e.kind || "task.event";
      const taskId = e.task_id || e.taskId || "";
      const runId = e.run_id || e.runId || "";
      const actor = e.actor || "system";
      const ts = e.created_at || e.ts || Date.now();
      const title = resolveTitle(e);
      const json = JSON.stringify(e, null, 2);

      return `
<details style="border-top:1px solid rgba(148,163,184,.2); padding:16px 0 22px 0;">
  <summary style="list-style:none; cursor:pointer; display:grid; grid-template-columns:120px 1fr; gap:16px; align-items:center; padding-left:12px;">

    <div>
      <div style="color:${color(kind)}; font-weight:700;">${status(kind)}</div>
      <div style="color:#64748b; font-size:12px;">${formatTime(ts)}</div>
    </div>

    <div>
      <div style="font-weight:700; color:#f8fafc;">${escapeHtml(title)}</div>
      <div style="margin-top:8px; display:flex; gap:16px; font-size:13px;">
        <span data-action="copy-id" style="color:#86efac; cursor:pointer; font-weight:700;">Copy ID</span>
        <span data-action="requeue" style="color:#facc15; cursor:pointer; font-weight:700;">Requeue</span>
        <span data-action="retry" style="color:#60a5fa; cursor:pointer; font-weight:700;">Retry</span>
      </div>
    </div>

  </summary>

  <div style="width:92%; margin:14px auto 0 auto; background:#111827; border:1px solid #334155; border-radius:12px; padding:16px 16px 18px 16px; overflow:hidden;">

    <div style="display:grid; grid-template-columns:140px minmax(0, 1fr); gap:8px 14px; color:#cbd5e1; font-size:13px;">
      <div style="color:#64748b;">Task ID</div><div style="color:#a78bfa; word-break:break-all;">${escapeHtml(taskId || "—")}</div>
      <div style="color:#64748b;">Run ID</div><div style="color:#a78bfa; word-break:break-all;">${escapeHtml(runId || "—")}</div>
      <div style="color:#64748b;">Event</div><div>${escapeHtml(kind)}</div>
      <div style="color:#64748b;">Actor</div><div style="word-break:break-all;">${escapeHtml(actor)}</div>
      <div style="color:#64748b;">Source</div><div>${escapeHtml(value(e, "source") || "—")}</div>
    </div>

    <details style="margin-top:14px;">
      <summary style="color:#60a5fa; cursor:pointer; font-size:12px;">View JSON</summary>
      <pre style="box-sizing:border-box; width:100%; margin:10px 0 0 0; background:#020617; padding:12px; border-radius:8px; font-size:11px; overflow:auto; max-height:180px; white-space:pre-wrap; color:#cbd5e1;">${escapeHtml(json)}</pre>
    </details>

  </div>
</details>
      `;
    }).join("");

    el.innerHTML = `
      <div style="display:flex; justify-content:space-between; margin-bottom:12px; color:#94a3b8;">
        <span>Execution Inspector: ${escapeHtml(state)}</span>
        <span>${events.length} events</span>
      </div>
      ${rows || '<div style="color:#64748b;">Waiting for events…</div>'}
    `;
  }

  function ingest(raw, type) {
    if (type === "hello" || type === "heartbeat") return;

    const e = parse(raw);
    if (!e) return;

    e.kind = e.kind || type;

    const taskId = e.task_id || e.taskId || "";
    if (!taskId) return;

    const id = e.id || `${e.kind}:${taskId}:${e.ts || e.created_at}`;
    if (seen.has(id)) return;
    seen.add(id);

    resolveTitle(e);

    events.unshift(e);
    if (events.length > maxEvents) events.length = maxEvents;

    render("Connected");
  }

  function start() {
    render("Connecting");

    const es = new EventSource(STREAM_URL);

    es.onopen = () => render("Connected");
    es.onerror = () => render("Connection error");

    es.onmessage = (e) => ingest(e.data, "message");

    ["task.created","task.started","task.completed","task.failed"].forEach(t => {
      es.addEventListener(t, e => ingest(e.data, t));
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, { once: true });
  } else {
    start();
  }
})();
