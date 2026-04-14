(() => {
  const STREAM_URL = "/events/task-events?cursor=0";
  const ROOT_ID = "mb-task-events-panel-anchor";

  if (window.__PHASE457_TASK_EVENTS_PANEL_ACTIVE__) return;
  window.__PHASE457_TASK_EVENTS_PANEL_ACTIVE__ = true;

  const root = document.getElementById(ROOT_ID);
  if (!root) return;

  let es = null;
  let reconnectTimer = null;
  let reconnectAttempt = 0;
  const maxItems = 24;
  const items = [];

  function escapeHtml(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function formatTime(value) {
    if (value == null || value === "") return "—";
    const d = new Date(value);
    if (!Number.isNaN(d.getTime())) return d.toLocaleString();
    return String(value);
  }

  function statusTone(status) {
    const s = String(status || "").toLowerCase();
    if (/fail|error|cancel|timeout|reject|blocked/.test(s)) return "#f87171";
    if (/success|complete|done|healthy|ok|approved/.test(s)) return "#4ade80";
    if (/queue|pending|wait|hold|retry/.test(s)) return "#facc15";
    if (/run|start|active|progress|created/.test(s)) return "#60a5fa";
    return "#cbd5e1";
  }

  function parseData(raw) {
    if (raw == null) return null;
    if (typeof raw === "object") return raw;
    try {
      return JSON.parse(raw);
    } catch (_) {
      return { message: String(raw) };
    }
  }

  function normalizeEvent(payload, eventName = "message") {
    const p = parseData(payload) || {};

    if (Array.isArray(p.events)) {
      return p.events.map((entry) => normalizeEvent(entry, eventName)).filter(Boolean);
    }

    const ts =
      p.ts ||
      p.timestamp ||
      p.created_at ||
      p.updated_at ||
      Date.now();

    const status =
      p.status ||
      p.kind ||
      p.type ||
      p.event ||
      eventName ||
      "event";

    const title =
      p.title ||
      p.message ||
      p.detail ||
      p.reason ||
      "Task event received";

    const meta = [];
    if (p.task_id || p.taskId) meta.push(`task=${p.task_id || p.taskId}`);
    if (p.run_id || p.runId) meta.push(`run=${p.run_id || p.runId}`);
    if (p.actor) meta.push(`actor=${p.actor}`);
    if (p.source) meta.push(`source=${p.source}`);

    return {
      id: String(p.id || `${status}:${ts}:${title}`),
      title: String(title),
      status: String(status),
      ts,
      meta: meta.join(" • ")
    };
  }

  function pushEvent(entry) {
    if (!entry) return;
    if (Array.isArray(entry)) {
      entry.forEach(pushEvent);
      return;
    }

    const existingIndex = items.findIndex((item) => item.id === entry.id);
    if (existingIndex >= 0) items.splice(existingIndex, 1);

    items.unshift(entry);
    if (items.length > maxItems) items.length = maxItems;
    render("live");
  }

  function render(state) {
    const rows = items.length
      ? items.map(item => `
        <div style="border:1px solid rgba(51,65,85,0.9); background:rgba(2,6,23,0.55); border-radius:0.85rem; padding:0.75rem;">
          <div style="display:flex; justify-content:space-between; gap:0.75rem; align-items:flex-start;">
            <div style="min-width:0;">
              <div style="color:#e2e8f0; font-size:0.92rem; line-height:1.35;">${escapeHtml(item.title)}</div>
              <div style="font-size:0.75rem; color:#94a3b8; margin-top:0.2rem;">${escapeHtml(formatTime(item.ts))}</div>
              ${item.meta ? `<div style="font-size:0.72rem; color:#94a3b8; margin-top:0.3rem;">${escapeHtml(item.meta)}</div>` : ""}
            </div>
            <div style="color:${statusTone(item.status)}; font-size:0.75rem; white-space:nowrap; text-transform:uppercase;">
              ${escapeHtml(item.status)}
            </div>
          </div>
        </div>`).join("")
      : `<div style="color:#94a3b8;">Waiting for task events…</div>`;

    root.innerHTML = `
      <div style="display:flex; flex-direction:column; gap:0.5rem;">
        <div style="font-size:0.75rem; color:#94a3b8;">
          ${state === "live" ? "Connected" : "Reconnecting…"}
        </div>
        ${rows}
      </div>
    `;
  }

  function clearReconnectTimer() {
    if (reconnectTimer) {
      clearTimeout(reconnectTimer);
      reconnectTimer = null;
    }
  }

  function scheduleReconnect() {
    clearReconnectTimer();
    reconnectAttempt += 1;
    render("reconnecting");
    reconnectTimer = setTimeout(connect, Math.min(5000, 1000 * reconnectAttempt));
  }

  function bindHandlers(source) {
    const handleEvent = (e) => {
      const entry = normalizeEvent(e.data, e.type || "message");
      if (entry) {
        reconnectAttempt = 0;
        pushEvent(entry);
      }
    };

    source.onopen = () => {
      reconnectAttempt = 0;
      render(items.length ? "live" : "live");
    };

    source.onmessage = handleEvent;
    source.addEventListener("task.event", handleEvent);
    source.addEventListener("task.created", handleEvent);
    source.addEventListener("task.updated", handleEvent);
    source.addEventListener("task.completed", handleEvent);
    source.addEventListener("task.failed", handleEvent);

    source.onerror = () => {
      try { source.close(); } catch (_) {}
      scheduleReconnect();
    };
  }

  function connect() {
    clearReconnectTimer();
    if (es) {
      try { es.close(); } catch (_) {}
      es = null;
    }

    render(items.length ? "reconnecting" : "reconnecting");
    es = new EventSource(STREAM_URL);
    bindHandlers(es);
  }

  render("reconnecting");
  connect();

  window.addEventListener("beforeunload", () => {
    clearReconnectTimer();
    if (es) {
      try { es.close(); } catch (_) {}
    }
  });
})();
