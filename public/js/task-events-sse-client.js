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

  function payload(e) {
    return e.payload && typeof e.payload === "object" ? e.payload : e;
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
    return "event";
  }

  function color(kind) {
    if (kind === "task.completed") return "#86efac";
    if (kind === "task.created") return "#93c5fd";
    if (kind === "task.failed") return "#f87171";
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
<details style="border-top:1px solid rgba(148,163,184,.2); padding:14px 0;">
  <summary style="list-style:none; cursor:pointer; display:grid; grid-template-columns:120px 1fr; gap:16px; align-items:center;">

    <div>
      <div style="color:${color(kind)}; font-weight:700;">${status(kind)}</div>
      <div style="color:#64748b; font-size:12px;">${formatTime(ts)}</div>
    </div>

    <div>
      <div style="font-weight:700; color:#f8fafc;">${escapeHtml(title)}</div>
      <div style="color:#a78bfa; font-size:12px; font-family:monospace;">
        task=${escapeHtml(shortId(taskId))}
        ${runId ? `· run=${escapeHtml(shortId(runId))}` : ""}
      </div>
    </div>

  </summary>

  <!-- ✅ FIX: removed left indentation -->
  <div style="width:92%; margin:12px auto 0 auto; background:#111827; border:1px solid #334155; border-radius:12px; padding:12px;">

    <div style="display:flex; justify-content:flex-end; gap:12px; margin-bottom:10px;">
      <span style="color:#86efac; cursor:pointer;">Copy ID</span>
      <span style="color:#facc15; cursor:pointer;">Requeue</span>
      <span style="color:#60a5fa; cursor:pointer;">Retry</span>
    </div>

    <div style="font-size:13px; color:#cbd5e1; margin-bottom:8px;">
      <b>${escapeHtml(kind)}</b> · actor=${escapeHtml(actor)}
    </div>

    <details>
      <summary style="color:#60a5fa; cursor:pointer; font-size:12px;">View JSON</summary>
      <pre style="margin-top:8px; background:#020617; padding:10px; border-radius:8px; font-size:11px; overflow:auto;">
${escapeHtml(json)}
      </pre>
    </details>

  </div>
</details>
      `;
    }).join("");

    el.innerHTML = `
      <div style="display:flex; justify-content:space-between; margin-bottom:12px; color:#94a3b8;">
        <span>Execution Inspector: ${state}</span>
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
