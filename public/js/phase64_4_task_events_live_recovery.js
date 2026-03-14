(() => {
  const OPS_URL = "/events/ops";
  const MAX_ROWS = 60;
  const RETRY_MS = 2000;

  let es = null;
  let reconnectTimer = null;
  let owned = null;
  let rows = [];
  let observer = null;

  function escapeHtml(value) {
    return String(value ?? "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function formatTs(value) {
    if (!value) return "—";
    const n = Number(value);
    const d = Number.isFinite(n) ? new Date(n) : new Date(value);
    if (Number.isNaN(d.getTime())) return String(value);
    return d.toLocaleTimeString([], {
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
    });
  }

  function statusTone(text) {
    const t = String(text || "").toLowerCase();
    if (/(fail|error|cancel|timeout|denied)/.test(t)) return "#f87171";
    if (/(complete|completed|success|done)/.test(t)) return "#4ade80";
    if (/(queue|queued|wait|pending|hold|sleep)/.test(t)) return "#fbbf24";
    if (/(run|start|resume|lease|dispatch|ack|progress|heartbeat|active|created)/.test(t)) return "#60a5fa";
    return "#cbd5e1";
  }

  function classifyEvent(payload) {
    const text = JSON.stringify(payload || {}).toLowerCase();
    return /(task|run|lease|dispatch|heartbeat|queue|queued|start|started|create|created|complete|completed|cancel|cancelled|failed|error|progress)/.test(text);
  }

  function normalizeEvent(payload) {
    const kind =
      payload?.kind ||
      payload?.event ||
      payload?.type ||
      payload?.name ||
      "event";

    const ts =
      payload?.ts ||
      payload?.timestamp ||
      payload?.created_at ||
      payload?.updated_at ||
      Date.now();

    const taskId =
      payload?.task_id ||
      payload?.taskId ||
      payload?.task ||
      payload?.id ||
      "—";

    const actor =
      payload?.actor ||
      payload?.agent ||
      payload?.owner ||
      payload?.source ||
      "system";

    const status =
      payload?.status ||
      payload?.state ||
      payload?.result ||
      kind;

    return { kind, ts, taskId, actor, status };
  }

  function getMountHost() {
    return (
      document.getElementById("mb-task-events-panel-anchor") ||
      document.getElementById("task-events-card") ||
      document.querySelector("#obs-panel-events .task-events-panel") ||
      document.querySelector("#obs-panel-events [data-phase61-task-events]") ||
      document.querySelector("#obs-panel-events [data-tab-panel='task-events']") ||
      document.querySelector("#obs-panel-events")
    );
  }

  function eventRowHtml(item) {
    return `
      <div
        data-phase64-task-event-row="1"
        style="
          display:grid;
          grid-template-columns: 160px 180px minmax(0,1fr);
          gap:14px;
          align-items:start;
          padding:12px 14px;
          border-top:1px solid rgba(148,163,184,.12);
          font-size:12px;
          line-height:1.35;
        "
      >
        <div style="color:#94a3b8; white-space:nowrap;">${escapeHtml(formatTs(item.ts))}</div>
        <div style="color:${statusTone(item.status)}; font-weight:600; white-space:nowrap;">${escapeHtml(item.kind)}</div>
        <div style="min-width:0; color:#cbd5e1; overflow-wrap:anywhere;">
          task=${escapeHtml(item.taskId)} · actor=${escapeHtml(item.actor)}
        </div>
      </div>
    `;
  }

  function applyHostContract(host) {
    host.style.display = "flex";
    host.style.flexDirection = "column";
    host.style.flex = "1 1 auto";
    host.style.minHeight = "0";
    host.style.height = "100%";
    host.style.width = "100%";
    host.style.overflow = "hidden";
    host.style.maxWidth = "100%";
    host.style.position = "relative";
    host.style.inset = "auto";
    host.style.margin = "0";
    host.style.transform = "none";
  }

  function buildOwnedPanel() {
    const root = document.createElement("section");
    root.setAttribute("data-phase64-task-events-root", "1");
    root.style.display = "flex";
    root.style.flexDirection = "column";
    root.style.flex = "1 1 auto";
    root.style.minHeight = "0";
    root.style.height = "100%";
    root.style.width = "100%";
    root.style.overflow = "hidden";
    root.style.border = "1px solid rgba(148,163,184,.16)";
    root.style.borderRadius = "20px";
    root.style.background = "rgba(2,6,23,.72)";
    root.style.backdropFilter = "blur(6px)";

    const header = document.createElement("div");
    header.style.display = "flex";
    header.style.alignItems = "center";
    header.style.justifyContent = "space-between";
    header.style.gap = "12px";
    header.style.padding = "16px 18px";
    header.style.borderBottom = "1px solid rgba(148,163,184,.12)";

    const title = document.createElement("div");
    title.textContent = "Task Events";
    title.style.fontSize = "14px";
    title.style.fontWeight = "600";
    title.style.letterSpacing = ".02em";
    title.style.color = "#e5e7eb";

    const status = document.createElement("div");
    status.setAttribute("data-phase64-task-events-status", "1");
    status.style.fontSize = "12px";
    status.style.color = "#94a3b8";
    status.textContent = "Connecting…";

    const body = document.createElement("div");
    body.setAttribute("data-phase64-task-events-body", "1");
    body.style.flex = "1 1 auto";
    body.style.minHeight = "0";
    body.style.height = "100%";
    body.style.overflowY = "auto";
    body.style.overflowX = "hidden";

    header.appendChild(title);
    header.appendChild(status);
    root.appendChild(header);
    root.appendChild(body);

    return { root, status, body };
  }

  function ensurePanel() {
    const host = getMountHost();
    if (!host) return null;

    applyHostContract(host);

    let root = host.querySelector(":scope > [data-phase64-task-events-root='1']");
    if (!root) {
      host.innerHTML = "";
      owned = buildOwnedPanel();
      host.appendChild(owned.root);
      root = owned.root;
    }

    if (!owned || owned.root !== root) {
      owned = {
        root,
        status: root.querySelector("[data-phase64-task-events-status]"),
        body: root.querySelector("[data-phase64-task-events-body]"),
      };
    }

    return owned;
  }

  function render() {
    const panel = ensurePanel();
    if (!panel) return;

    if (!rows.length) {
      panel.status.textContent = es ? "Live" : "Connecting…";
      panel.body.innerHTML = `
        <div style="padding:18px; color:#e5e7eb; font-size:13px;">
          Waiting for events…
        </div>
      `;
      return;
    }

    panel.status.textContent = es ? `Live · ${rows.length} buffered` : "Reconnecting…";
    panel.body.innerHTML = rows.map(eventRowHtml).join("");
  }

  function pushEvent(payload) {
    if (!classifyEvent(payload)) return;
    rows.unshift(normalizeEvent(payload));
    if (rows.length > MAX_ROWS) rows.length = MAX_ROWS;
    render();
  }

  function scheduleReconnect() {
    if (reconnectTimer) return;
    reconnectTimer = window.setTimeout(() => {
      reconnectTimer = null;
      connect();
    }, RETRY_MS);
  }

  function connect() {
    const panel = ensurePanel();
    if (panel) panel.status.textContent = "Connecting…";

    if (es) {
      es.close();
      es = null;
    }

    const next = new EventSource(OPS_URL);
    es = next;

    next.onopen = () => {
      const p = ensurePanel();
      if (p) p.status.textContent = rows.length ? `Live · ${rows.length} buffered` : "Live";
    };

    next.onmessage = (event) => {
      try {
        const payload = JSON.parse(event.data);
        pushEvent(payload);
      } catch (_err) {
        // ignore malformed frames
      }
    };

    next.onerror = () => {
      const p = ensurePanel();
      if (p) p.status.textContent = "Reconnecting…";
      if (es) {
        es.close();
        es = null;
      }
      scheduleReconnect();
    };
  }

  function installObserver() {
    if (observer) observer.disconnect();
    observer = new MutationObserver(() => {
      ensurePanel();
      render();
    });
    observer.observe(document.body, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ["class", "hidden", "style"],
    });
  }

  function start() {
    ensurePanel();
    render();
    connect();
    installObserver();
    window.setInterval(render, 1500);
  }

  window.__PHASE64_TASK_EVENTS_RECOVERY__ = {
    reconnect: connect,
    rows: () => rows.length,
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, { once: true });
  } else {
    start();
  }
})();
