(function () {
  if (window.__PHASE23_TASK_EVENTS_BRIDGE_STARTED) return;
  window.__PHASE23_TASK_EVENTS_BRIDGE_STARTED = true;

  const es = new EventSource("/events/task-events");
  window.__taskEventsES = es;

  function emit(kind, payload) {
    try { window.dispatchEvent(new CustomEvent("matilda.taskEvent", { detail: { kind, payload } })); } catch (_) {}
  }

  function normalize(kind, payload) {
    // v22 task-events stream includes:
    // - event: hello {kind:"task-events", cursor, ts}
    // - event: heartbeat {ts, cursor}
    // - event: task.event or task.state with payload {task:{...}} or {id,status,agent,...}
    //
    // We map into: task.created / task.completed / task.failed / task.progress
    const p = payload || {};
    const task = p.task || p;
    const status = (task.status || p.status || "").toLowerCase();
    const id = task.id || p.id || p.task_id;

    if (!status) return { kind: kind || "task.event", task, id };

    if (status in {"queued":1,"running":1,"started":1}) return { kind: "task.progress", task, id };
    if (status in {"completed":1,"done":1,"success":1}) return { kind: "task.completed", task, id };
    if (status in {"failed":1,"error":1}) return { kind: "task.failed", task, id };
    return { kind: "task.progress", task, id };
  }

  function line(kind, n) {
    const t = n.task || {};
    const id = n.id != null ? String(n.id) : (t.task_id ? String(t.task_id) : "?");
    const agent = (t.agent || t.target || "").toString().toUpperCase();
    const a = agent ? ` → ${agent}` : "";
    if (kind === "task.completed") return `🎉 task.completed [${id}]${a}`;
    if (kind === "task.failed") return `❌ task.failed [${id}]${a}`;
    if (kind === "task.progress") return `⏳ task.${(t.status || "update")} [${id}]${a}`;
    if (kind === "heartbeat") return null;
    if (kind === "hello") return null;
    return `ℹ️ ${kind} [${id}]${a}`;
  }

  function push(kind, payload) {
    const n = normalize(kind, payload);
    emit(n.kind, n);
    const msg = line(n.kind, n);
    if (!msg) return;
    const fn = window.__MATILDA_CHAT_APPEND_SYSTEM || window.__chatAppendSystem || null;
    if (typeof fn === "function") {
      try { fn(msg); } catch (_) {}
    }
  }

  es.addEventListener("message", (ev) => {
    try {
      const payload = JSON.parse(ev.data || "{}");
      const kind = payload.kind || payload.event || "task.event";
      push(kind, payload);
    } catch (_) {}
  });

  // Also listen to specific event names if server uses event: task.* / heartbeat / hello
  ["hello", "heartbeat", "task.created", "task.completed", "task.failed", "task.event", "task.state", "task.update"].forEach((k) => {
    es.addEventListener(k, (ev) => {
      try { push(k, JSON.parse(ev.data || "{}")); } catch (_) {}
    });
  });

  es.onerror = () => emit("task-events.error", { ts: Date.now() });
})();
