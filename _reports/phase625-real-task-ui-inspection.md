# Phase 625 Real Task UI Inspection

## dashboard-tasks-widget.js
/**
 * Tasks Widget + Runs Panel
 * - Stable DOM shell (prevents runs panel remount churn)
 * - Debounced task refresh
 * - Conservative polling
 * - No SSE-triggered fetch storm
 */
(() => {
  const API = {
    list: "/api/tasks",
    complete: "/api/tasks/complete",
  };

  const SELECTORS = [
    "#tasks-widget",
    "#tasksWidget",
    "[data-tasks-widget]",
    "[data-widget='tasks']",
  ];

  const TASK_POLL_MS = 15000;
  const RUNS_POLL_MS = 15000;
  const TASK_EVENT_DEBOUNCE_MS = 1000;

  const state = {
    tasks: [],
    loading: false,
    lastError: null,
    inflightComplete: new Set(),
    shellMounted: false,
    taskFetchPromise: null,
    taskFetchTimer: null,
    runsPanelMounted: false,
    runsPanelTimer: null,
  };

  function $(sel, root = document) {
    return root.querySelector(sel);
  }

  function findMount() {
    for (const sel of SELECTORS) {
      const el = $(sel);
      if (el) return el;
    }
    return null;
  }

  function esc(s) {
    return String(s ?? "")
      .replaceAll("&", "&amp;")
      .replaceAll("<", "&lt;")
      .replaceAll(">", "&gt;")
      .replaceAll('"', "&quot;")
      .replaceAll("'", "&#39;");
  }

  function ensureShell() {
    const mount = findMount();
    if (!mount) return null;

    if (!state.shellMounted) {
      mount.innerHTML = `
        <div data-tasks-shell="1">
          <div data-tasks-error></div>
          <div data-tasks-list></div>
          <div data-runs-host></div>
        </div>
      `;
      state.shellMounted = true;
    }

    const shell = mount.querySelector('[data-tasks-shell="1"]');
    return {
      mount,
      shell,
      errorEl: shell?.querySelector("[data-tasks-error]") || null,
      listEl: shell?.querySelector("[data-tasks-list]") || null,
      runsHost: shell?.querySelector("[data-runs-host]") || null,
    };
  }

  async function apiJson(url, opts = {}) {
    const res = await fetch(url, {
      method: opts.method || "GET",
      headers: { "Content-Type": "application/json" },
      body: opts.body ? JSON.stringify(opts.body) : undefined,
    });
    const json = await res.json();
    if (!res.ok) throw new Error(json?.error || "Request failed");
    return json;
  }

  function render() {
    const ui = ensureShell();
    if (!ui) return;

    if (ui.errorEl) {
      ui.errorEl.innerHTML = state.lastError
        ? `<div style="color:red">${esc(state.lastError)}</div>`
        : "";
    }

    if (ui.listEl) {
      ui.listEl.innerHTML = `
        <div>
          ${state.loading && !state.tasks.length ? `<div style="opacity:.7">Loading…</div>` : ""}
          ${
            state.tasks.length
              ? state.tasks
                  .map(
                    (t) => `
              <div style="display:flex;justify-content:space-between;gap:8px">
                <span>${esc(t.title)}</span>
                ${
                  ["complete", "completed", "done"].includes(String(t.status || "").toLowerCase())
                    ? `<span style="opacity:.5;font-size:12px">Completed</span>`
                    : `<button data-id="${esc(t.id)}">Complete</button>`
                }
              </div>
            `
                  )
                  .join("")
              : !state.loading
              ? `<div style="opacity:.7">No tasks found.</div>`
              : ""
          }
        </div>
      `;

      ui.listEl.querySelectorAll("button[data-id]").forEach((btn) => {
        btn.onclick = () => completeTask(btn.dataset.id);
      });
    }

    if (ui.runsHost && !state.runsPanelMounted) {
      try {
        renderRunsPanel(ui.runsHost);
        state.runsPanelMounted = true;
      } catch (e) {
        console.warn("[runs] panel mount failed", e);
      }
    }
  }

  async function fetchTasksNow() {
    if (state.taskFetchPromise) return state.taskFetchPromise;

    state.taskFetchPromise = (async () => {
      state.loading = true;
      render();
      try {
        const data = await apiJson(API.list);
        state.tasks = (data.tasks || []).map((t) => ({
          id: String(t.task_id ?? t.taskId ?? t.id),
          title: t.title || "",
          status: t.status || "",
        }));
        state.lastError = null;
      } catch (e) {
        state.lastError = e?.message || String(e);
      } finally {
        state.loading = false;
        render();
        state.taskFetchPromise = null;
      }
    })();

    return state.taskFetchPromise;
  }

  function scheduleFetchTasks(delayMs = 0) {
    if (state.taskFetchTimer) clearTimeout(state.taskFetchTimer);
    state.taskFetchTimer = setTimeout(() => {
      state.taskFetchTimer = null;
      fetchTasksNow().catch((e) => console.warn("[tasks] refresh failed", e));
    }, delayMs);
  }

  async function completeTask(taskId) {
    if (!taskId || state.inflightComplete.has(taskId)) return;
    state.inflightComplete.add(taskId);
    render();

    try {
      await apiJson(API.complete, {
        method: "POST",
        body: { task_id: taskId },
      });
      state.lastError = null;
    } catch (e) {
      state.lastError = e?.message || String(e);
    } finally {
      state.inflightComplete.delete(taskId);
      scheduleFetchTasks(0);
    }
  }

  function buildRunsQuery({ limit, task_status, is_terminal, since_ts }) {
    const p = new URLSearchParams();
    if (limit != null && String(limit).trim() !== "") p.set("limit", String(limit));
    for (const s of task_status || []) p.append("task_status", String(s));
    if (is_terminal === "true" || is_terminal === "false") p.set("is_terminal", is_terminal);
    if (since_ts != null && String(since_ts).trim() !== "") p.set("since_ts", String(since_ts));
    return p.toString();
  }

  async function fetchRuns({ limit, task_status, is_terminal, since_ts }) {
    const q = buildRunsQuery({ limit, task_status, is_terminal, since_ts });
    const url = "/api/runs" + (q ? "?" + q : "");
    const r = await fetch(url, { headers: { Accept: "application/json" } });
    const j = await r.json().catch(() => ({}));
    if (!r.ok) throw new Error(j?.error || j?.detail || "HTTP_" + r.status);
    return j;
  }

  function fmtTs(ms) {
    const n = Number(ms);
    if (!Number.isFinite(n)) return "";
    try {

## phase565_recent_tasks_wire.js
(function () {
  function text(value, fallback) {
    return String(value || fallback || "").trim();
  }

  function formatTime(value) {
    if (!value) return "time unavailable";
    const d = new Date(value);
    if (Number.isNaN(d.getTime())) return String(value);
    return d.toLocaleString();
  }

  function statusClass(status) {
    const s = String(status || "").toLowerCase();
    if (s.includes("complete")) return "text-green-400";
    if (s.includes("running")) return "text-yellow-400";
    if (s.includes("queued")) return "text-blue-400";
    if (s.includes("failed")) return "text-red-400";
    return "text-gray-400";
  }

  function renderRecentTasks(tasks) {
    const mount = document.getElementById("recentTasks");
    if (!mount) return;

    mount.innerHTML = "";

    const items = Array.isArray(tasks) ? tasks.slice(0, 8) : [];

    if (items.length === 0) {
      mount.textContent = "No recent tasks yet.";
      return;
    }

    const list = document.createElement("div");
    list.style.display = "grid";
    list.style.gap = "0.75rem";

    items.forEach(function (task) {
      const card = document.createElement("div");
      card.className = "rounded-lg border border-gray-700 bg-gray-950/60 p-3";

      const title = document.createElement("div");
      title.className = "text-sm font-semibold text-gray-100";
      title.textContent = text(task.title || task.task_id || task.id, "Untitled task");

      const meta = document.createElement("div");
      meta.className = "mt-2 text-xs leading-5";

      const statusSpan = document.createElement("span");
      statusSpan.className = statusClass(task.status);
      statusSpan.textContent = text(task.status, "unknown");

      meta.appendChild(document.createTextNode("Status: "));
      meta.appendChild(statusSpan);
      meta.appendChild(document.createTextNode(" · Updated: " + formatTime(task.updated_at || task.created_at)));

      card.appendChild(title);
      card.appendChild(meta);
      list.appendChild(card);
    });

    mount.appendChild(list);
  }

  async function refreshRecentTasks() {
    try {
      const res = await fetch("/api/tasks", { cache: "no-store" });
      if (!res.ok) throw new Error("tasks fetch failed");
      const data = await res.json();
      renderRecentTasks(Array.isArray(data.tasks) ? data.tasks : []);
    } catch (_) {
      renderRecentTasks([]);
    }
  }

  function startRecentTasksWire() {
    refreshRecentTasks();
}

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", startRecentTasksWire, { once: true });
  } else {
    startRecentTasksWire();
  }
})();

## task-events-sse-client.js
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

    container.querySelector('[data-action="copy-id"]')?.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopPropagation();
      navigator.clipboard.writeText(taskId);
    });

    container.querySelector('[data-action="requeue"]')?.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopPropagation();
      delegateTask({
        title: title,
        kind: "retry",
        source: "execution-inspector",
        meta: {
          retry_of_task_id: taskId,
          retry_mode: "standard"
        },
        strategy: "standard"
      });
    });

    container.querySelector('[data-action="retry"]')?.addEventListener("click", (event) => {
      event.preventDefault();
      event.stopPropagation();
      delegateTask({
        title: title,
        kind: "retry",
        source: "execution-inspector",
        meta: {
          retry_of_task_id: taskId,
          retry_mode: "fresh-context"
        },
        strategy: "fresh-context"
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
      const json = JSON.stringify(e, null, 2);

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
      task=${escapeHtml(shortId(taskId))} ${runId ? "• run=" + escapeHtml(shortId(runId)) : ""}
    </div>

    <details style="margin-top:10px;">
      <summary style="cursor:pointer;">Advanced ▸</summary>
      <pre style="margin-top:8px; font-size:11px;">${escapeHtml(json)}</pre>
    </details>
  </div>
</details>
      `;
    }).join("");

    el.innerHTML = `
      <div style="display:flex; justify-content:space-between; margin-bottom:12px;">
        <span>Execution Inspector: ${escapeHtml(state)}</span>
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

## operatorGuidance.sse.js
(() => {
  if (window.__OPERATOR_GUIDANCE_STREAM_ACTIVE__) return;
  window.__OPERATOR_GUIDANCE_STREAM_ACTIVE__ = true;

  const RESPONSE_EL = document.getElementById("operator-guidance-response");
  const META_EL = document.getElementById("operator-guidance-meta");

  let eventSource = null;

  function closeStream() {
    if (eventSource) {
      eventSource.close();
      eventSource = null;
    }
  }

  function firstNonEmpty(...values) {
    for (const value of values) {
      if (value === null || value === undefined) continue;
      const text = String(value).trim();
      if (text) return text;
    }
    return "";
  }

  function normalizePayload(raw) {
    let data = raw;
    try {
      if (typeof raw === "string") data = JSON.parse(raw);
    } catch (_) {}

    const reduction = data?.reduction || {};
    const envelope = reduction?.envelope || {};
    const guidanceItems = Array.isArray(envelope?.guidance) ? envelope.guidance : [];

    const guidanceLines = guidanceItems
      .map((item) =>
        firstNonEmpty(
          item?.summary,
          item?.message,
          item?.headline,
          item?.detail,
          item?.reason
        )
      )
      .filter(Boolean);

    const response = firstNonEmpty(
      guidanceLines.join("\n\n"),
      reduction?.confidenceReason,
      "No guidance available"
    );

    const metaLines = [];

    const confidence = firstNonEmpty(reduction?.surfaceConfidence);
    if (confidence) {
      metaLines.push(`Confidence: ${confidence}`);
    }

    const confidenceReason = firstNonEmpty(reduction?.confidenceReason);
    if (confidenceReason) {
      metaLines.push(`Reason: ${confidenceReason}`);
    }

    const signalCount =
      reduction?.signalCount !== undefined && reduction?.signalCount !== null
        ? String(reduction.signalCount).trim()
        : "";
    if (signalCount) {
      metaLines.push(`Signals: ${signalCount}`);
    }

    if (reduction?.conflictingSignals === true) {
      metaLines.push("Conflicts: detected");
    }

    const sourceSet = new Set();
    if (data?.source) sourceSet.add(String(data.source).trim());
    guidanceItems.forEach((item) => {
      const src = firstNonEmpty(item?.source, item?.domain);
      if (src) sourceSet.add(src);
    });

    const sources = Array.from(sourceSet).filter(Boolean).join(", ");
    if (sources) {
      metaLines.push(`Sources: ${sources}`);
    }

    return { response, metaLines };
  }

  function applyPayload(raw) {
    const normalized = normalizePayload(raw);

    if (RESPONSE_EL && normalized.response) {
      RESPONSE_EL.textContent = normalized.response;
    }

    if (META_EL && normalized.metaLines.length) {
      META_EL.innerText = normalized.metaLines.join("\n");
    }
  }

  function attachHandlers(es) {
    const handleEvent = (event) => {
      try {
        applyPayload(event.data);
      } catch (_) {}
    };

    es.onmessage = handleEvent;
    es.addEventListener("operator_guidance", handleEvent);
    es.addEventListener("operator-guidance", handleEvent);
    es.addEventListener("guidance", handleEvent);

    es.onerror = () => {
      closeStream();
    };
  }

  function startStream() {
    if (eventSource) return;
    eventSource = new EventSource("/events/operator-guidance");
    attachHandlers(eventSource);
  }

  startStream();

  document.addEventListener("visibilitychange", () => {
    if (document.visibilityState === "hidden") {
      closeStream();
    }
  });

  window.addEventListener("beforeunload", () => {
    closeStream();
  });
})();
