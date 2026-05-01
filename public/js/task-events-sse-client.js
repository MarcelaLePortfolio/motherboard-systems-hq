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

  function payload(e) {
    return e && e.payload && typeof e.payload === "object" ? e.payload : {};
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

  function contextText(e) {
    const kind = e.kind || "task.event";
    const p = payload(e);
    const retryMode = p.retry_mode || "";
    const executionMode = p.execution_mode || "";

    const isFresh = retryMode === "fresh-context" || executionMode === "rebuild_context";
    const isRetry = retryMode || p.retry_of_task_id;

    if (kind === "task.completed" && isFresh) return "Retry executed with fresh context and completed successfully.";
    if (kind === "task.completed" && isRetry) return "Retry executed and completed successfully.";
    if (kind === "task.completed") return "Task completed successfully.";

    if (kind === "task.created" && isFresh) return "Retry entered the pipeline with fresh-context routing.";
    if (kind === "task.created" && isRetry) return "Retry entered the execution pipeline.";
    if (kind === "task.created") return "Task entered the execution pipeline.";

    if (kind === "task.failed" && isRetry) return "Retry failed during execution.";
    if (kind === "task.failed") return "Task failed during execution.";

    if (kind === "task.started") return "Worker started processing this task.";

    return "System event recorded.";
  }

  async function delegateTask(body) {
    try {
      const res = await fetch("/api/delegate-task", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(body)
      });
      return await res.json();
    } catch (err) {
      console.error("delegateTask failed", err);
    }
  }

  function wireActions(container, e) {
    const taskId = e.task_id || e.taskId;
    const title = resolveTitle(e);

    container.querySelector('[data-action="copy-id"]')?.addEventListener("click", () => {
      navigator.clipboard.writeText(taskId);
    });

    container.querySelector('[data-action="requeue"]')?.addEventListener("click", () => {
      delegateTask({
        title: title,
        kind: "requeue",
        source: "execution-inspector",
        meta: { retry_of_task_id: taskId }
      });
    });

    container.querySelector('[data-action="retry"]')?.addEventListener("click", () => {
      delegateTask({
        title: title,
        kind: "retry",
        source: "execution-inspector",
        meta: {
          retry_of_task_id: taskId,
          retry_mode: "fresh-context"
        }
      });
    });
  }

  function render(state) {
    const el = root();
    if (!el) return;

    const rows = events.map((e, i) => {
      const kind = e.kind || "task.event";
      const taskId = e.task_id || e.taskId || "";
      const runId = e.run_id || e.runId || "";
      const ts = e.created_at || e.ts || Date.now();
      const title = resolveTitle(e);

      return `
<details data-idx="${i}" style="border-top:1px solid rgba(148,163,184,.2); padding:16px 0;">
  <summary style="list-style:none; cursor:pointer; display:grid; grid-template-columns:120px 1fr; gap:16px; padding-left:12px;">
    <div>
      <div style="color:${kind === "task.completed" ? "#86efac" : "#93c5fd"}; font-weight:700;">
        ${kind.replace("task.", "")}
      </div>
      <div style="color:#64748b; font-size:12px;">${formatTime(ts)}</div>
    </div>

    <div>
      <div style="font-weight:700;">${escapeHtml(title)}</div>
      <div style="margin-top:8px; display:flex; gap:16px;">
        <span data-action="copy-id" style="color:#86efac; cursor:pointer;">Copy ID</span>
        <span data-action="requeue" style="color:#facc15; cursor:pointer;">Requeue</span>
        <span data-action="retry" style="color:#60a5fa; cursor:pointer;">Retry</span>
      </div>
    </div>
  </summary>

  <div style="width:92%; margin:14px auto 0 auto; background:#111827; border:1px solid #334155; border-radius:12px; padding:16px;">
    <div>${escapeHtml(contextText(e))}</div>

    <div style="margin-top:8px; color:#a78bfa; font-family:monospace;">
      task=${shortId(taskId)} ${runId ? "• run=" + shortId(runId) : ""}
    </div>

    <details style="margin-top:10px;">
      <summary style="cursor:pointer;">Advanced ▸</summary>
      <pre style="margin-top:8px; font-size:11px;">${escapeHtml(JSON.stringify(e, null, 2))}</pre>
    </details>
  </div>
</details>
      `;
    }).join("");

    el.innerHTML = `
      <div style="display:flex; justify-content:space-between; margin-bottom:12px;">
        <span>Execution Inspector: ${state}</span>
        <span>${events.length} events</span>
      </div>
      ${rows}
    `;

    document.querySelectorAll("details[data-idx]").forEach((node) => {
      const idx = Number(node.getAttribute("data-idx"));
      wireActions(node, events[idx]);
    });
  }

  function ingest(raw, type) {
    if (type === "hello" || type === "heartbeat") return;

    const e = parse(raw);
    if (!e) return;

    e.kind = e.kind || type;

    const taskId = e.task_id || e.taskId;
    if (!taskId) return;

    const id = e.id || `${e.kind}:${taskId}`;
    if (seen.has(id)) return;
    seen.add(id);

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
