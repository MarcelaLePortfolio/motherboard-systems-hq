(function () {
  if (window.__PHASE23_TASK_EVENTS_BRIDGE_STARTED) return;
  window.__PHASE23_TASK_EVENTS_BRIDGE_STARTED = true;

  const es = new EventSource("/events/task-events");
  window.__taskEventsES = es;

  function emit(kind, payload) {
    try {
      window.dispatchEvent(new CustomEvent("matilda.taskEvent", { detail: { kind, payload } }));
    } catch (_) {}
  }

  function line(kind, payload) {
    const tid = payload?.task_id ? ` [${payload.task_id}]` : "";
    const tgt = payload?.target ? ` → ${String(payload.target).toUpperCase()}` : "";
    if (kind === "task.created") return `✅ task.created${tid}${tgt}`;
    if (kind === "task.completed") return `🎉 task.completed${tid}${tgt}`;
    if (kind === "task.failed") return `❌ task.failed${tid}${tgt}`;
    return `ℹ️ ${kind}${tid}${tgt}`;
  }

  function push(kind, payload) {
    emit(kind, payload);
    const fn = window.__MATILDA_CHAT_APPEND_SYSTEM || window.__chatAppendSystem || null;
    if (typeof fn === "function") {
      try { fn(line(kind, payload)); } catch (_) {}
    }
  }

  es.addEventListener("message", (ev) => {
    try {
      const payload = JSON.parse(ev.data || "{}");
      const kind = payload.kind || payload.event || "task.event";
      push(kind, payload);
    } catch (_) {}
  });

  ["task.created", "task.completed", "task.failed"].forEach((k) => {
    es.addEventListener(k, (ev) => {
      try { push(k, JSON.parse(ev.data || "{}")); } catch (_) {}
    });
  });

  es.onerror = () => emit("task-events.error", { ts: Date.now() });
})();
