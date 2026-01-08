(() => {
  // Phase 22: bind task-events SSE -> Task Delegation + status UI (best-effort)

  const TASK_EVENT_NAME = "mb.task.event";
  const tasks = new Map();

  const STATUS_CLASS = {
    queued: "task-status-queued",
    done: "task-status-done",
    failed: "task-status-failed",
  };

  function normStatus(s) {
    const v = String(s ?? "").toLowerCase();
    if (v === "queued" || v === "pending") return "queued";
    if (v === "done" || v === "complete" || v === "completed") return "done";
    if (v === "failed" || v === "error") return "failed";
    return v || "unknown";
  }

  function pluckId(ev) {
    return ev?.task_id ?? ev?.taskId ?? ev?.id ?? ev?.task?.id ?? null;
  }

  function pluckTask(ev) {
    const t = ev?.task && typeof ev.task === "object" ? ev.task : null;
    const id = pluckId(ev);
    const status =
      ev?.status ??
      ev?.payload?.status ??
      t?.status ??
      (ev?.kind === "task.created" ? "queued" : null);

    return {
      id: id != null ? String(id) : null,
      status: status != null ? normStatus(status) : null,
      title: t?.title ?? ev?.title ?? null,
      agent: t?.agent ?? ev?.agent ?? null,
      error: ev?.error ?? ev?.payload?.error ?? t?.error ?? null,
      updated_at: t?.updated_at ?? ev?.ts ?? Date.now(),
    };
  }

  function setStatusOnNode(node, status) {
    if (!node) return;
    const s = normStatus(status);
    node.setAttribute("data-task-status", s);
    node.classList?.remove(...Object.values(STATUS_CLASS));
    if (STATUS_CLASS[s]) node.classList?.add(STATUS_CLASS[s]);

    const sub =
      node.querySelector?.("[data-task-field='status']") ||
      node.querySelector?.(".task-status") ||
      node.querySelector?.(".status") ||
      null;
    if (sub) sub.textContent = s;
  }

  function updateTaskRowUI(task) {
    if (!task?.id) return;
    const id = String(task.id);
    const nodes = [
      document.getElementById(`task-${id}`),
      document.getElementById(`task_${id}`),
      document.querySelector?.(`[data-task-id="${CSS.escape(id)}"]`),
      document.querySelector?.(`[data-taskid="${CSS.escape(id)}"]`),
    ].filter(Boolean);

    for (const n of nodes) setStatusOnNode(n, task.status);
  }

  function updateCountersUI() {
    let queued = 0, done = 0, failed = 0;
    for (const t of tasks.values()) {
      const s = normStatus(t.status);
      if (s === "queued") queued++;
      else if (s === "done") done++;
      else if (s === "failed") failed++;
    }

    const map = [
      ["queued", queued],
      ["done", done],
      ["failed", failed],
    ];

    for (const [k, v] of map) {
      const el =
        document.getElementById(`task-count-${k}`) ||
        document.getElementById(`tasks-${k}-count`) ||
        document.querySelector?.(`[data-task-count="${k}"]`) ||
        null;
      if (el) el.textContent = String(v);
    }
  }

  function ingestTask(task) {
    if (!task?.id) return;
    const id = String(task.id);
    const prev = tasks.get(id) || {};
    const next = { ...prev, ...task, id, status: task.status ?? prev.status };
    tasks.set(id, next);
    updateTaskRowUI(next);
    updateCountersUI();
  }

  function onTaskEvent(ev) {
    const t = pluckTask(ev);
    if (!t.id && ev?.kind) {
      if (ev.kind === "task.completed") t.status = "done";
      if (ev.kind === "task.failed") t.status = "failed";
    }
    if (t.id) ingestTask(t);
  }

  function attach() {
    if (window.__PHASE22_TASK_UI_BOUND) return;
    window.__PHASE22_TASK_UI_BOUND = true;

    window.addEventListener(TASK_EVENT_NAME, (e) => {
      try { if (window.__UI_DEBUG || window.__PHASE22_DEBUG) console.log("[phase22] mb.task.event", e.detail); onTaskEvent(e.detail); } catch {}
    });

    window.__PHASE22_TASK_UI = { tasks }; console.log("[phase22] bindings attached");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", attach, { once: true });
  } else {
    attach();
  }
})();
