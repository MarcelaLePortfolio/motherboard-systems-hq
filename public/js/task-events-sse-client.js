(function () {
  const STREAM_URL = "/events/task-events?cursor=0";
  const ROOT_ID = "mb-task-events-panel-anchor";

  if (window.__TASK_EVENTS_SSE_CLIENT_ACTIVE__) return;
  window.__TASK_EVENTS_SSE_CLIENT_ACTIVE__ = true;

  const events = [];
  const seen = new Set();
  const titlesByTaskId = new Map(); // ✅ NEW: persist titles
  const maxEvents = 80;

  function root() {
    return document.getElementById(ROOT_ID);
  }

  function escapeHtml(value) {
    return String(value ?? "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function parse(raw) {
    try { return JSON.parse(raw); } catch { return null; }
  }

  // ✅ NEW: title resolver (safe, no UI change yet)
  function resolveTitle(event) {
    const taskId = event.task_id || event.taskId || "";
    const direct =
      event.title ||
      event.message ||
      event.msg ||
      event.detail ||
      event.payload?.title ||
      "";

    if (direct && !String(direct).startsWith("{")) {
      titlesByTaskId.set(taskId, direct);
      return direct;
    }

    return titlesByTaskId.get(taskId) || "Untitled task";
  }

  function render(state) {
    const el = root();
    if (!el) return;

    const rows = events.length
      ? events.map((event) => {
          const kind = event.kind || event.type || "event";
          const taskId = event.task_id || event.taskId || "unknown";
          const actor = event.actor || "system";
          const ts = event.created_at || event.ts || Date.now();
          const eventId = event.id || `${kind}:${taskId}:${ts}`;

          const title = resolveTitle(event); // ✅ use persisted title

          return `
            <div data-task-event-id="${escapeHtml(eventId)}" style="border-bottom:1px solid rgba(75,85,99,.55); padding:.45rem 0; font-family:ui-monospace,SFMono-Regular,Menlo,monospace; font-size:.75rem; line-height:1.4;">
              <div style="color:#93c5fd;">${escapeHtml(kind)} <span style="color:#64748b;">task=${escapeHtml(taskId)}</span></div>
              <div style="color:#e5e7eb; font-weight:600;">${escapeHtml(title)}</div>
              <div style="color:#64748b;">actor=${escapeHtml(actor)} • ${escapeHtml(ts)}</div>
            </div>
          `;
        }).join("")
      : `<div style="color:#94a3b8;">Connected — waiting for task lifecycle events…</div>`;

    el.innerHTML = `
      <div style="display:flex; justify-content:space-between; margin-bottom:.5rem;">
        <div style="color:#94a3b8;">Execution Inspector: ${escapeHtml(state)}</div>
        <div style="color:#64748b;">${events.length} events</div>
      </div>
      ${rows}
    `;
  }

  function ingest(raw, eventType) {
    if (eventType === "hello" || eventType === "heartbeat") return;

    const event = parse(raw);
    if (!event) return;

    event.kind = event.kind || eventType;

    const taskId = event.task_id || event.taskId || "";
    if (!taskId) return;

    const eventId = event.id || `${event.kind}:${taskId}:${event.ts || event.created_at}`;
    if (seen.has(eventId)) return;
    seen.add(eventId);

    resolveTitle(event); // ✅ persist title early

    events.unshift(event);
    if (events.length > maxEvents) events.length = maxEvents;

    render("Connected");
  }

  function start() {
    render("Connecting");

    const es = new EventSource(STREAM_URL);

    es.onopen = () => render("Connected");
    es.onerror = () => render("Connection error");

    es.onmessage = (event) => ingest(event.data, "message");

    ["task.created","task.started","task.completed","task.failed"].forEach((type) => {
      es.addEventListener(type, (event) => ingest(event.data, type));
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, { once: true });
  } else {
    start();
  }
})();
