(() => {
  const OPS_URL = "/events/ops";
  const MAX_ROWS = 60;
  const RETRY_MS = 2000;

  let es = null;
  let reconnectTimer = null;
  let owned = null;
  let rows = [];

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
    return d.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit", second: "2-digit" });
  }

  function statusTone(text) {
    const t = String(text || "").toLowerCase();
    if (/(fail|error|cancel|timeout|denied)/.test(t)) return "#f87171";
    if (/(complete|completed|success|done)/.test(t)) return "#4ade80";
    if (/(queue|queued|wait|pending|hold|sleep)/.test(t)) return "#fbbf24";
    if (/(run|start|resume|lease|dispatch|ack|progress|heartbeat|active)/.test(t)) return "#60a5fa";
    return "#cbd5e1";
  }

  function classifyEvent(payload) {
    const text = JSON.stringify(payload || {}).toLowerCase();
    return /(task|run|lease|dispatch|heartbeat|queue|queued|start|started|complete|completed|cancel|cancelled|failed|error|progress)/.test(text);
  }

  function normalize(payload) {
    const p = payload && typeof payload === "object" ? payload : {};
    const event = p.payload && typeof p.payload === "object" ? p.payload : p;

    const kind =
      p.kind ||
      p.event ||
      event.kind ||
      event.event ||
      event.type ||
      event.status ||
      "task.event";

    const taskId =
      event.task_id ||
      event.taskId ||
      p.task_id ||
      p.taskId ||
      "—";

    const runId =
      event.run_id ||
      event.runId ||
      p.run_id ||
      p.runId ||
      "—";

    const actor =
      event.actor ||
      event.agent ||
      event.owner ||
      p.actor ||
      p.agent ||
      "system";

    const ts =
      event.ts ||
      event.updated_at ||
      event.updatedAt ||
      event.created_at ||
      event.createdAt ||
      p.ts ||
      Date.now();

    const detailParts = [];
    if (taskId && taskId !== "—") detailParts.push(`task=${taskId}`);
    if (runId && runId !== "—") detailParts.push(`run=${runId}`);
    if (actor) detailParts.push(`actor=${actor}`);

    return {
      id: `${ts}:${kind}:${taskId}:${runId}:${Math.random().toString(36).slice(2, 8)}`,
      kind: String(kind),
      ts,
      detail: detailParts.join(" · "),
    };
  }

  function ensureOwnedPanel() {
    const anchor = document.getElementById("mb-task-events-panel-anchor");
    if (!anchor) return null;

    if (owned && owned.anchor === anchor) return owned;

    anchor.innerHTML = "";

    const shell = document.createElement("div");
    shell.setAttribute("data-phase64-task-events-recovery", "true");
    shell.style.display = "flex";
    shell.style.flexDirection = "column";
    shell.style.height = "100%";
    shell.style.minHeight = "0";
    shell.style.overflow = "hidden";
    shell.style.gap = "10px";

    const status = document.createElement("div");
    status.setAttribute("data-phase64-task-events-status", "true");
    status.style.fontSize = "12px";
    status.style.opacity = ".72";
    status.textContent = "Task Events recovery stream booting…";

    const list = document.createElement("div");
    list.setAttribute("data-phase64-task-events-list", "true");
    list.style.display = "flex";
    list.style.flexDirection = "column";
    list.style.gap = "8px";
    list.style.flex = "1 1 auto";
    list.style.minHeight = "0";
    list.style.overflowY = "auto";
    list.style.overflowX = "hidden";
    list.style.paddingRight = "4px";

    shell.appendChild(status);
    shell.appendChild(list);
    anchor.appendChild(shell);

    owned = { anchor, shell, status, list };
    render();
    return owned;
  }

  function render() {
    const panel = ensureOwnedPanel();
    if (!panel) return;

    if (!rows.length) {
      panel.list.innerHTML =
        '<div class="rounded-xl border border-slate-800 bg-slate-950/60 px-3 py-3 text-sm text-slate-400">Waiting for live task events…</div>';
      return;
    }

    panel.list.innerHTML = rows
      .map(
        (row) => `
        <div class="rounded-xl border border-slate-800 bg-slate-950/60 px-3 py-3" data-phase64-task-event-row="${escapeHtml(row.id)}">
          <div class="flex items-start justify-between gap-3">
            <div class="min-w-0">
              <div class="text-sm font-medium text-slate-100 break-all">${escapeHtml(row.kind)}</div>
              <div class="mt-1 text-xs text-slate-400 break-all">${escapeHtml(row.detail || "—")}</div>
            </div>
            <div class="shrink-0 text-xs uppercase tracking-wide" style="color:${statusTone(row.kind)}">${escapeHtml(formatTs(row.ts))}</div>
          </div>
        </div>`
      )
      .join("");
  }

  function setStatus(text) {
    const panel = ensureOwnedPanel();
    if (!panel) return;
    panel.status.textContent = text;
  }

  function pushRow(payload) {
    if (!classifyEvent(payload)) return;
    rows.unshift(normalize(payload));
    rows = rows.slice(0, MAX_ROWS);
    setStatus(`Live task events connected · showing ${rows.length} event${rows.length === 1 ? "" : "s"}`);
    render();
  }

  function connect() {
    window.clearTimeout(reconnectTimer);
    if (es) {
      es.close();
      es = null;
    }

    ensureOwnedPanel();
    setStatus("Connecting live task events…");

    es = new EventSource(OPS_URL);

    es.onopen = () => {
      setStatus(`Live task events connected · showing ${rows.length} event${rows.length === 1 ? "" : "s"}`);
    };

    es.onmessage = (evt) => {
      let payload = null;
      try {
        payload = JSON.parse(evt.data);
      } catch {
        payload = { raw: evt.data, kind: "ops.message" };
      }
      pushRow(payload);
    };

    es.onerror = () => {
      setStatus("Task Events stream disconnected · retrying…");
      if (es) {
        es.close();
        es = null;
      }
      window.clearTimeout(reconnectTimer);
      reconnectTimer = window.setTimeout(connect, RETRY_MS);
    };
  }

  function start() {
    ensureOwnedPanel();
    connect();
  }

  window.__PHASE64_TASK_EVENTS_RECOVERY__ = {
    start,
    reconnect: connect,
    getRows: () => rows.slice(),
  };

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, { once: true });
  } else {
    start();
  }
})();
