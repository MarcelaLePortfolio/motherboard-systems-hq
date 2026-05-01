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

  function escapeHtml(value) {
    return String(value ?? "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function parse(raw) {
    try {
      return JSON.parse(raw);
    } catch {
      return null;
    }
  }

  function shortId(value) {
    const s = String(value || "");
    if (!s) return "unknown";
    if (s.length <= 18) return s;
    return s.slice(0, 10) + "…" + s.slice(-6);
  }

  function formatTime(value) {
    const d = new Date(Number(value) || value);
    if (Number.isNaN(d.getTime())) return String(value || "");
    return d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", second: "2-digit" });
  }

  function normalizeTitle(event) {
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

  function toneFor(kind) {
    if (kind === "task.completed") return "#86efac";
    if (kind === "task.failed") return "#f87171";
    if (kind === "task.started") return "#facc15";
    if (kind === "task.created") return "#93c5fd";
    return "#cbd5e1";
  }

  function labelFor(kind) {
    return String(kind || "task.event").replace(/^task\./, "");
  }

  function render(state) {
    const el = root();
    if (!el) return;

    const rows = events.length
      ? events.map((event) => {
          const kind = event.kind || event.type || "task.event";
          const taskId = event.task_id || event.taskId || "unknown";
          const actor = event.actor || "system";
          const runId = event.run_id || event.runId || "";
          const ts = event.created_at || event.ts || Date.now();
          const eventId = event.id || `${kind}:${taskId}:${ts}`;
          const title = normalizeTitle(event);
          const color = toneFor(kind);
          const json = JSON.stringify(event, null, 2);

          return `
            <div data-task-event-id="${escapeHtml(eventId)}" data-task-id="${escapeHtml(taskId)}" style="border-bottom:1px solid rgba(75,85,99,.45); padding:.7rem 0; font-family:ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,Segoe UI,sans-serif; font-size:.82rem; line-height:1.4;">
              <div style="display:flex; justify-content:space-between; gap:1rem; align-items:flex-start;">
                <div style="min-width:0;">
                  <div style="display:flex; gap:.55rem; align-items:center; flex-wrap:wrap;">
                    <span style="color:${color}; font-weight:800;">${escapeHtml(labelFor(kind))}</span>
                    <span style="color:#64748b;">${escapeHtml(formatTime(ts))}</span>
                    <span style="color:#94a3b8;">actor=${escapeHtml(actor)}</span>
                  </div>
                  <div style="color:#e5e7eb; font-weight:700; margin-top:.25rem;">${escapeHtml(title)}</div>
                  <div style="color:#a78bfa; margin-top:.18rem; font-family:ui-monospace,SFMono-Regular,Menlo,monospace; font-size:.74rem;">
                    task=${escapeHtml(shortId(taskId))}${runId ? ` · run=${escapeHtml(shortId(runId))}` : ""}
                  </div>
                </div>

                <div style="display:flex; gap:.7rem; white-space:nowrap; font-size:.75rem;">
                  <span data-action="requeue" style="cursor:pointer; color:#facc15;">Requeue</span>
                  <span data-action="retry" style="cursor:pointer; color:#60a5fa;">Retry</span>
                </div>
              </div>

              <details data-expanded-panel style="margin-top:.45rem;">
                <summary style="cursor:pointer; color:#94a3b8; font-size:.74rem;">View JSON</summary>
                <pre style="margin-top:.4rem; white-space:pre-wrap; overflow:auto; border:1px solid rgba(75,85,99,.45); border-radius:.55rem; padding:.65rem; color:#cbd5e1; background:rgba(15,23,42,.65); font-family:ui-monospace,SFMono-Regular,Menlo,monospace; font-size:.72rem;">${escapeHtml(json)}</pre>
              </details>
            </div>
          `;
        }).join("")
      : `<div style="color:#94a3b8; font-family:ui-sans-serif,system-ui; font-size:.82rem;">Connected — waiting for task lifecycle events…</div>`;

    el.innerHTML = `
      <div style="display:flex; justify-content:space-between; gap:.75rem; align-items:center; margin-bottom:.65rem; font-family:ui-sans-serif,system-ui;">
        <div style="font-size:.78rem; color:#94a3b8;">Execution Inspector: ${escapeHtml(state)}</div>
        <div style="font-size:.72rem; color:#64748b;">${events.length} event${events.length === 1 ? "" : "s"}</div>
      </div>
      <div style="flex:1 1 auto; min-height:0; overflow:auto;">${rows}</div>
    `;
  }

  function ingest(raw, eventType) {
    if (eventType === "hello" || eventType === "heartbeat") return;

    const event = parse(raw);
    if (!event) return;

    event.kind = event.kind || eventType || "task.event";

    const taskId = event.task_id || event.taskId || "";
    if (!taskId || taskId === "unknown") return;

    const eventId = event.id || `${event.kind}:${taskId}:${event.ts || event.created_at || ""}`;
    if (seen.has(eventId)) return;
    seen.add(eventId);

    normalizeTitle(event);

    events.unshift(event);
    if (events.length > maxEvents) events.length = maxEvents;

    try {
      window.dispatchEvent(new CustomEvent("mb.task.event", { detail: event }));
    } catch {}

    render("Connected");
  }

  function start() {
    render("Connecting");

    const es = new EventSource(STREAM_URL);

    es.onopen = () => render("Connected");
    es.onerror = () => render("Connection error");

    es.onmessage = (event) => ingest(event.data, "message");

    ["task.event", "task.created", "task.started", "task.updated", "task.completed", "task.failed", "error"].forEach((type) => {
      es.addEventListener(type, (event) => ingest(event.data, type));
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, { once: true });
  } else {
    start();
  }
})();
