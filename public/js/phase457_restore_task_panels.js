(() => {
  const STREAM_URL = "/events/task-events";
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

    return {
      id: String(p.id || `${eventName}:${ts}`),
      title: String(title),
      status: String(status),
      ts,
      meta: p.source ? `source=${p.source}` : ""
    };
  }

  function pushEvent(entry) {
    if (!entry) return;
    if (Array.isArray(entry)) {
      entry.forEach(pushEvent);
      return;
    }

    items.unshift(entry);
    if (items.length > maxItems) items.length = maxItems;
    render("live");
  }

  function render(state) {
    const rows = items.length
      ? items.map(item => `
        <div style="border:1px solid rgba(51,65,85,0.9); background:rgba(2,6,23,0.55); border-radius:0.85rem; padding:0.75rem;">
          <div style="display:flex; justify-content:space-between;">
            <div>
              <div style="color:#e2e8f0;">${escapeHtml(item.title)}</div>
              <div style="font-size:0.75rem; color:#94a3b8;">${escapeHtml(formatTime(item.ts))}</div>
            </div>
            <div style="color:${statusTone(item.status)}; font-size:0.75rem;">
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

  function connect() {
    es = new EventSource(STREAM_URL);

    es.onopen = () => {
      reconnectAttempt = 0;
      render("live");
    };

    es.onmessage = (e) => {
      pushEvent(normalizeEvent(e.data));
    };

    es.onerror = () => {
      es.close();
      render("reconnecting");
      setTimeout(connect, 2000);
    };
  }

  render("reconnecting");
  connect();
})();
