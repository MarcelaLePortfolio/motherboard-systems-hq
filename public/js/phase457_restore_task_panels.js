(() => {
  const STREAM_URL = "/events/task-events?cursor=0";
  const ROOT_ID = "mb-task-events-panel-anchor";

  if (window.__PHASE457_TASK_EVENTS_PANEL_ACTIVE__) return;
  window.__PHASE457_TASK_EVENTS_PANEL_ACTIVE__ = true;

  function getRoot() { return document.getElementById(ROOT_ID); }
  const root = getRoot();
    if (!root) return;

  let es = null;
  let reconnectTimer = null;
  let reconnectAttempt = 0;
  let selectedEventId = "";
  let copiedTaskId = "";
  let showJsonForEventId = "";
  const maxItems = 120;
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
    if (!Number.isNaN(d.getTime())) {
      return d.toLocaleTimeString([], {
        hour: "2-digit",
        minute: "2-digit",
        second: "2-digit",
      });
    }
    return String(value);
  }

  function statusTone(kind) {
    const s = String(kind || "").toLowerCase();
    if (/fail|error|cancel|timeout|reject|blocked/.test(s)) return "#f87171";
    if (/success|complete|done|healthy|ok|approved/.test(s)) return "#4ade80";
    if (/queue|pending|wait|hold|retry/.test(s)) return "#facc15";
    if (/run|start|active|progress|created/.test(s)) return "#60a5fa";
    return "#cbd5e1";
  }

  function lifecycleLabel(kind) {
    const s = String(kind || "").toLowerCase();
    if (/fail|error/.test(s)) return "✕ Failed";
    if (/complete|success|done/.test(s)) return "✓ Completed";
    if (/run|start|claim|active|progress/.test(s)) return "▶ Running";
    if (/created|queue|pending|wait/.test(s)) return "● Queued";
    return "";
  }

  function shortId(id) {
    if (!id) return "—";
    return String(id).slice(-6);
  }

  function isActiveKind(kind) {
    return /run|start|claim|active|progress/.test(String(kind || "").toLowerCase());
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
    const kind = String(
      p.kind ||
      p.type ||
      p.event ||
      eventName ||
      "event"
    );

    if (kind === "hello" || kind === "heartbeat") {
      return null;
    }

    const ts =
      p.ts ||
      p.timestamp ||
      p.created_at ||
      p.updated_at ||
      Date.now();

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
      kind,
      title: String(title),
      ts,
      taskId: String(taskId),
      runId: String(runId),
      actor: String(actor),
      source: String(source),
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

    let lastTaskId = "";

    const rows = items.length
      ? items.map((item) => {
          const metaParts = [];
          if (item.taskId) metaParts.push(`task=${item.taskId}`);
          if (item.runId) metaParts.push(`run=${item.runId}`);
          if (item.actor) metaParts.push(`actor=${item.actor}`);
          if (item.source) metaParts.push(`source=${item.source}`);

          const label = lifecycleLabel(item.kind) || item.kind;
          const id = shortId(item.taskId);
          const sameTask = item.taskId && item.taskId === lastTaskId;
          const isSelected = item.id === selectedEventId;
          const rowStyle = [
            "padding:0.42rem 0",
            "cursor:pointer",
            `border-bottom:1px solid ${sameTask ? "rgba(51,65,85,0.25)" : "rgba(51,65,85,0.5)"}`,
            sameTask ? "padding-left:0.65rem" : "",
            isActiveKind(item.kind) ? "background:rgba(255,255,255,0.04)" : "",
            isSelected ? "background:rgba(59,130,246,0.12)" : "",
            isSelected ? "outline:1px solid rgba(147,197,253,0.6)" : ""
          ].filter(Boolean).join("; ");
          lastTaskId = item.taskId;

          return `
            <div data-task-event-id="${escapeHtml(item.id)}" style="${rowStyle}">
              <div style="display:grid; grid-template-columns:auto auto 1fr; gap:0.65rem; align-items:start; font-family:ui-monospace,SFMono-Regular,Menlo,monospace; font-size:0.76rem; line-height:1.45;">
                <span style="color:#94a3b8; white-space:nowrap;">${escapeHtml(formatTime(item.ts))}</span>
                <span style="color:${statusTone(item.kind)}; white-space:nowrap;">[${escapeHtml(id)}] ${escapeHtml(label)}</span>
                <div style="min-width:0;">
                  <div style="color:#e2e8f0;">${escapeHtml(item.title)}</div>
                  ${metaParts.length ? `<div style="margin-top:0.14rem; color:#94a3b8;">${escapeHtml(metaParts.join(" • "))}</div>` : ""}
                </div>
              </div>
            </div>
          `;
        }).join("")
      : `<div style="color:#94a3b8; font-family:ui-monospace,SFMono-Regular,Menlo,monospace; font-size:0.78rem;">No task events yet — waiting for activity…<br/><span style="opacity:0.7;">Tasks will appear here as they are created and executed.</span></div>`;

    const selectedItem = items.find((i) => i.id === selectedEventId);

    const selectedPanel = selectedItem
      ? `
        <div style="border:1px solid rgba(51,65,85,0.9); background:rgba(15,23,42,0.6); border-radius:0.75rem; padding:0.5rem 0.8rem;">
          <div style="font-size:0.7rem; color:#94a3b8; margin-bottom:0.2rem;">Selected Task</div>
          <div style="font-family:ui-monospace,SFMono-Regular,Menlo,monospace; font-size:0.78rem; color:#e2e8f0;">
            [${escapeHtml(shortId(selectedItem.taskId))}] ${escapeHtml(lifecycleLabel(selectedItem.kind) || selectedItem.kind)}
          </div>
          <div style="font-size:0.8rem; color:#cbd5f5; margin-top:0.15rem;">
            ${escapeHtml(selectedItem.title)}
          </div>
          <div style="font-size:0.7rem; color:#64748b; margin-top:0.2rem;">
            ${escapeHtml(formatTime(selectedItem.ts))}
          </div>

          <div style="font-size:0.7rem; color:#64748b; margin-top:0.25rem; font-family:ui-monospace,SFMono-Regular,Menlo,monospace;">
            ${selectedItem.taskId ? `<div>task_id: ${escapeHtml(selectedItem.taskId)}</div>` : ""}
            ${selectedItem.runId ? `<div>run_id: ${escapeHtml(selectedItem.runId)}</div>` : ""}
            ${selectedItem.actor ? `<div>actor: ${escapeHtml(selectedItem.actor)}</div>` : ""}
            ${selectedItem.source ? `<div>source: ${escapeHtml(selectedItem.source)}</div>` : ""}
            <div>kind: ${escapeHtml(selectedItem.kind)}</div>
          </div>

          <div style="display:flex; gap:0.5rem; margin-top:0.4rem; font-size:0.7rem;">
            <span data-action="inspect" style="cursor:pointer; color:#93c5fd;">Inspect</span>
            <span data-action="copy" style="cursor:pointer; color:#86efac;">${copiedTaskId && copiedTaskId === selectedItem.taskId ? "Copied ✓" : "Copy ID"}</span>
            <span data-action="json" style="cursor:pointer; color:#c4b5fd;">${showJsonForEventId === selectedItem.id ? "Hide JSON" : "View JSON"}</span>
            <span style="opacity:0.4;">Retry</span>
            <span style="opacity:0.4;">Cancel</span>
          </div>

          ${showJsonForEventId === selectedItem.id ? `
            <pre style="margin-top:0.45rem; max-height:9rem; overflow:auto; background:rgba(2,6,23,0.65); border:1px solid rgba(51,65,85,0.65); border-radius:0.6rem; padding:0.5rem; color:#cbd5e1; font-size:0.68rem; line-height:1.45;">${escapeHtml(JSON.stringify(selectedItem, null, 2))}</pre>
          ` : ""}
        </div>
      `
      : `
        <div style="font-size:0.72rem; color:#64748b;">No task selected</div>
      `;

    root.innerHTML = `
      <div style="display:flex; flex-direction:column; gap:0.55rem; min-height:12rem;">
        <div style="display:flex; justify-content:space-between; gap:0.75rem; align-items:center;">
          <div style="font-size:0.75rem; color:#94a3b8;">${statusLabel}</div>
          <div style="font-size:0.72rem; color:#64748b;">Live log • replay from cursor=0 • ${items.length} event${items.length === 1 ? "" : "s"}</div>
        </div>

        ${selectedPanel}

        <div style="border:1px solid rgba(51,65,85,0.9); background:rgba(2,6,23,0.42); border-radius:0.85rem; padding:0.35rem 0.8rem; overflow:auto; max-height:18rem;">
          ${rows}
        </div>
      </div>
    `;

    root.querySelectorAll("[data-task-event-id]").forEach((row) => {
      row.addEventListener("click", () => {
        selectedEventId = row.getAttribute("data-task-event-id") || "";
        const selected = items.find((item) => item.id === selectedEventId);
        if (selected) {
          console.log("Selected task:", {
            taskId: selected.taskId,
            kind: selected.kind,
            title: selected.title,
            ts: selected.ts
          });
        }
        render(state);
      });

      row.addEventListener("mouseenter", () => {
        if (row.getAttribute("data-task-event-id") === selectedEventId) return;
        row.style.background = "rgba(255,255,255,0.03)";
      });

      row.addEventListener("mouseleave", () => {
        if (row.getAttribute("data-task-event-id") === selectedEventId) return;
        row.style.background = "";
      });
    });

    root.querySelectorAll("[data-action]").forEach((el) => {
      el.addEventListener("click", (e) => {
        e.stopPropagation();
        const action = el.getAttribute("data-action");
        const selected = items.find((i) => i.id === selectedEventId);
        if (!selected) return;

        if (action === "inspect") {
          console.log("Inspect task:", selected);
        }

        if (action === "json") {
          showJsonForEventId = showJsonForEventId === selected.id ? "" : selected.id;
          render(state);
        }

        if (action === "copy" && selected.taskId) {
          navigator.clipboard.writeText(selected.taskId);
          copiedTaskId = selected.taskId;
          console.log("Copied task ID:", selected.taskId);
          render(state);
          setTimeout(() => {
            if (copiedTaskId === selected.taskId) {
              copiedTaskId = "";
              render(state);
            }
          }, 1500);
        }
      });
    });
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
      try {
        source.close();
      } catch (_) {}
    };
  }

  function connect() {
    clearReconnectTimer();
    if (es) {
      try {
        es.close();
      } catch (_) {}
      es = null;
    }

    es = new EventSource(STREAM_URL);
    if (!es) {
      return;
    }
    bindHandlers(es);
  }


  render("connecting");
  connect();

  window.addEventListener("beforeunload", () => {
    clearReconnectTimer();
    if (es) {
      try {
        es.close();
      } catch (_) {}
    }
  });
})();

document.addEventListener("DOMContentLoaded", () => {
});
