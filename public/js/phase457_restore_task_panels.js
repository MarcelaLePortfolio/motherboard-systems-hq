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
  const maxItems = 60;
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

    const ts =
      p.ts ||
      p.timestamp ||
      p.created_at ||
      p.updated_at ||
      Date.now();

    const kind =
      p.kind ||
      p.type ||
      p.event ||
      eventName ||
      "event";

    if (kind === "hello" || kind === "heartbeat") {
      return null;
    }

    const title =
      p.title ||
      p.message ||
      p.detail ||
      p.reason ||
      p.summary ||
      "Task event received";

    const taskId = p.task_id || p.taskId || "";
    const runId = p.run_id || p.runId || "";
    const actor = p.actor || "";
    const source = p.source || "";

    return {
      id: String(p.id || `${kind}:${ts}:${taskId}:${runId}:${title}`),
      kind: String(kind),
      title: String(title),
      ts,
      taskId: String(taskId || ""),
      runId: String(runId || ""),
      actor: String(actor || ""),
      source: String(source || "")
    };
  }

  function pushEvent(entry) {
    if (!entry) return;

    const existingIndex = items.findIndex((item) => item.id === entry.id);
    if (existingIndex >= 0) {
      items.splice(existingIndex, 1);
    }

    items.unshift(entry);
    if (items.length > maxItems) items.length = maxItems;
    render("live");
  }

  function render(state) {
    const statusLabel = state === "live" ? "Connected" : "Reconnecting…";

    const rows = items.length
      ? items.map((item) => {
          const metaParts = [];
          if (item.taskId) metaParts.push(`task=${item.taskId}`);
          if (item.runId) metaParts.push(`run=${item.runId}`);
          if (item.actor) metaParts.push(`actor=${item.actor}`);
          if (item.source) metaParts.push(`source=${item.source}`);

          return `
            <div style="border-bottom:1px solid rgba(51,65,85,0.6); padding:0.5rem 0;">
              <div style="display:flex; gap:0.6rem; align-items:flex-start; font-family:ui-monospace,SFMono-Regular,Menlo,monospace; font-size:0.76rem; line-height:1.45;">
                <span style="color:#94a3b8; white-space:nowrap;">${escapeHtml(formatTime(item.ts))}</span>
                <span style="color:${statusTone(item.kind)}; white-space:nowrap; text-transform:uppercase;">${escapeHtml(item.kind)}</span>
                <div style="min-width:0; flex:1; color:#e2e8f0;">
                  <div>${escapeHtml(item.title)}</div>
                  ${metaParts.length ? `<div style="color:#94a3b8; margin-top:0.18rem;">${escapeHtml(metaParts.join(" • "))}</div>` : ""}
                </div>
              </div>
            </div>
          `;
        }).join("")
      : `<div style="color:#94a3b8; font-family:ui-monospace,SFMono-Regular,Menlo,monospace; font-size:0.78rem;">No task events in stream yet.</div>`;

    root.innerHTML = `
      <div style="display:flex; flex-direction:column; gap:0.55rem; min-height:12rem;">
        <div style="display:flex; justify-content:space-between; gap:0.75rem; align-items:center;">
          <div style="font-size:0.75rem; color:#94a3b8;">${statusLabel}</div>
          <div style="font-size:0.72rem; color:#64748b;">Replay from cursor=0 • ${items.length} event${items.length === 1 ? "" : "s"}</div>
        </div>
        <div style="border:1px solid rgba(51,65,85,0.9); background:rgba(2,6,23,0.42); border-radius:0.85rem; padding:0.6rem 0.8rem; overflow:auto; max-height:18rem;">
          ${rows}
        </div>
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
      render("live");
    };

    source.onmessage = handleEvent;
    source.addEventListener("task.event", handleEvent);
    source.addEventListener("task.created", handleEvent);
    source.addEventListener("task.updated", handleEvent);
    source.addEventListener("task.completed", handleEvent);
    source.addEventListener("task.failed", handleEvent);
    source.addEventListener("error", handleEvent);

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
