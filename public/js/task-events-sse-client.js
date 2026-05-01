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
    return s.slice(0, 8) + "…" + s.slice(-5);
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

  function badgeFor(kind) {
    if (kind === "task.completed") return "Completed";
    if (kind === "task.failed") return "Failed";
    if (kind === "task.started") return "Started";
    if (kind === "task.created") return "Created";
    return String(kind || "Event").replace(/^task\./, "");
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
          const isTerminal = kind === "task.completed" || kind === "task.failed";

          return `
            <details data-expanded-panel data-task-event-id="${escapeHtml(eventId)}" data-task-id="${escapeHtml(taskId)}" style="border-bottom:1px solid rgba(75,85,99,.42); padding:.62rem 0; font-family:ui-sans-serif,system-ui,-apple-system,BlinkMacSystemFont,Segoe UI,sans-serif;">
              <summary style="cursor:pointer; list-style:none;">
                <div style="display:grid; grid-template-columns:120px 1fr 140px; gap:14px; align-items:start;">
                  <div>
                    <div style="color:${color}; font-weight:800; font-size:.82rem;">${escapeHtml(badgeFor(kind))}</div>
                    <div style="color:#64748b; font-size:.72rem; margin-top:2px;">${escapeHtml(formatTime(ts))}</div>
                  </div>

                  <div style="min-width:0;">
                    <div style="color:#e5e7eb; font-weight:750; font-size:.86rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">${escapeHtml(title)}</div>
                    <div style="color:#a78bfa; margin-top:3px; font-family:ui-monospace,SFMono-Regular,Menlo,monospace; font-size:.72rem; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
                      task=${escapeHtml(shortId(taskId))}${runId ? ` · run=${escapeHtml(shortId(runId))}` : ""}
                    </div>
                  </div>

                  <div style="color:#94a3b8; font-size:.72rem; text-align:right; white-space:nowrap; overflow:hidden; text-overflow:ellipsis;">
                    ${isTerminal ? "worker" : escapeHtml(actor)}
                  </div>
                </div>
              </summary>

              <div style="margin-top:.55rem; margin-left:120px; padding:.65rem .75rem; border:1px solid rgba(75,85,99,.38); border-radius:.65rem; background:rgba(15,23,42,.45);">
                <div style="display:flex; justify-content:space-between; gap:1rem; align-items:center; flex-wrap:wrap;">
                  <div style="color:#cbd5e1; font-size:.78rem;">
                    <strong style="color:#e5e7eb;">${escapeHtml(kind)}</strong>
                    <span style="color:#64748b;"> · actor=${escapeHtml(actor)}</span>
                  </div>

                  <div style="display:flex; gap:.85rem; font-size:.78rem;">
                    <span data-action="requeue" style="cursor:pointer; color:#facc15; font-weight:700;">Requeue</span>
                    <span data-action="retry" style="cursor:pointer; color:#60a5fa; font-weight:700;">Retry</span>
                  </div>
                </div>

                <details style="margin-top:.55rem;">
                  <summary style="cursor:pointer; color:#94a3b8; font-size:.74rem;">View JSON</summary>
                  <pre style="margin-top:.4rem; white-space:pre-wrap; overflow:auto; max-height:180px; border:1px solid rgba(75,85,99,.45); border-radius:.55rem; padding:.65rem; color:#cbd5e1; background:rgba(2,6,23,.72); font-family:ui-monospace,SFMono-Regular,Menlo,monospace; font-size:.7rem;">${escapeHtml(json)}</pre>
                </details>
              </div>
            </details>
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
