(() => {
  // Phase 22: bind task-events SSE -> Task Delegation + status UI (best-effort)

  const TASK_EVENT_NAME = "mb.task.event";
  const tasks = new Map();
  const runningTaskIds = new Set();
  const terminalTaskIds = new Set();
  const completedTaskIds = new Set();
  const failedTaskIds = new Set();

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

  function isTerminalKind(kind) {
    const v = String(kind ?? "").toLowerCase();
    return (
      v === "task.completed" ||
      v === "task.failed" ||
      v === "task.cancelled" ||
      v === "task.canceled"
    );
  }

  function isRunningKind(kind) {
    const v = String(kind ?? "").toLowerCase();
    return (
      v === "task.created" ||
      v === "task.started" ||
      v === "task.running"
    );
  }

  function isSuccessKind(kind) {
    const v = String(kind ?? "").toLowerCase();
    return v === "task.completed";
  }

  function isFailureKind(kind) {
    const v = String(kind ?? "").toLowerCase();
    return (
      v === "task.failed" ||
      v === "task.cancelled" ||
      v === "task.canceled"
    );
  }

  function isTerminalStatus(status) {
    const v = normStatus(status);
    return (
      v === "done" ||
      v === "failed" ||
      v === "cancelled" ||
      v === "canceled" ||
      v === "complete" ||
      v === "completed" ||
      v === "error"
    );
  }

  function isSuccessStatus(status) {
    const v = normStatus(status);
    return v === "done" || v === "complete" || v === "completed";
  }

  function isFailureStatus(status) {
    const v = normStatus(status);
    return v === "failed" || v === "cancelled" || v === "canceled" || v === "error";
  }

  function isRunningStatus(status) {
    const v = normStatus(status);
    return (
      v === "queued" ||
      v === "pending" ||
      v === "running" ||
      v === "started" ||
      v === "active" ||
      v === "in_progress" ||
      v === "in-progress"
    );
  }

  function updateRunningTaskDerivation(ev, task) {
    const id = task?.id ? String(task.id) : null;
    if (!id) return;

    const kind = String(ev?.kind ?? "").toLowerCase();
    const status =
      task?.status ??
      ev?.status ??
      ev?.payload?.status ??
      ev?.task?.status ??
      null;

    if (terminalTaskIds.has(id)) {
      runningTaskIds.delete(id);
      return;
    }

    if (isTerminalKind(kind) || isTerminalStatus(status)) {
      runningTaskIds.delete(id);
      terminalTaskIds.add(id);
      return;
    }

    if (isRunningKind(kind) || isRunningStatus(status)) {
      runningTaskIds.add(id);
    }
  }

  function updateCompletedTaskDerivation(ev, task) {
    const id = task?.id ? String(task.id) : null;
    if (!id) return;

    const kind = String(ev?.kind ?? "").toLowerCase();
    const status =
      task?.status ??
      ev?.status ??
      ev?.payload?.status ??
      ev?.task?.status ??
      null;

    if (completedTaskIds.has(id)) return;

    if (isFailureKind(kind) || isFailureStatus(status)) return;

    if (isSuccessKind(kind) || isSuccessStatus(status)) {
      completedTaskIds.add(id);
    }
  }

  function updateFailedTaskDerivation(ev, task) {
    const id = task?.id ? String(task.id) : null;
    if (!id) return;

    const kind = String(ev?.kind ?? "").toLowerCase();
    const status =
      task?.status ??
      ev?.status ??
      ev?.payload?.status ??
      ev?.task?.status ??
      null;

    if (failedTaskIds.has(id)) return;

    if (isSuccessKind(kind) || isSuccessStatus(status)) return;

    if (isFailureKind(kind) || isFailureStatus(status)) {
      failedTaskIds.add(id);
    }
  }

  function pluckId(ev) {
    return ev?.task_id ?? ev?.taskId ?? ev?.task?.id ?? null;
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

  function updateCounterNode(key, value) {
    const el =
      document.getElementById(`task-count-${key}`) ||
      document.getElementById(`tasks-${key}-count`) ||
      document.querySelector?.(`[data-task-count="${key}"]`) ||
      null;

    if (el) el.textContent = String(value);
  }

  function updateCountersUI() {
    let queued = 0;
    let done = 0;
    let failed = 0;

    for (const t of tasks.values()) {
      const s = normStatus(t.status);
      if (s === "queued") queued++;
      else if (s === "done") done++;
      else if (s === "failed") failed++;
    }

    updateCounterNode("queued", queued);
    updateCounterNode("done", done);
    updateCounterNode("failed", failed);
    updateCounterNode("running", runningTaskIds.size);
    updateCounterNode("completed", completedTaskIds.size);
    updateCounterNode("failed-terminal", failedTaskIds.size);
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

    updateRunningTaskDerivation(ev, t);
    updateCompletedTaskDerivation(ev, t);
    updateFailedTaskDerivation(ev, t);

    if (t.id) ingestTask(t);
    else updateCountersUI();
  }

  function attach() {
    if (window.__PHASE22_TASK_UI_BOUND) return;
    window.__PHASE22_TASK_UI_BOUND = true;

    window.addEventListener(TASK_EVENT_NAME, (e) => {
      try {
        if (window.__UI_DEBUG || window.__PHASE22_DEBUG) {
          console.log("[phase22] mb.task.event", e.detail);
        }
        onTaskEvent(e.detail);
      } catch {}
    });

    window.__PHASE22_TASK_UI = {
      tasks,
      runningTaskIds,
      terminalTaskIds,
      completedTaskIds,
      failedTaskIds,
      getRunningTasksCount: () => runningTaskIds.size,
      getCompletedTasksCount: () => completedTaskIds.size,
      getFailedTasksCount: () => failedTaskIds.size,
    };
    console.log("[phase22] bindings attached");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", attach, { once: true });
  } else {
    attach();
  }
})();
