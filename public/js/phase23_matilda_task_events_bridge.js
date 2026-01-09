(function () {
  if (window.__PHASE23_TASK_EVENTS_BRIDGE_STARTED) return;
  window.__PHASE23_TASK_EVENTS_BRIDGE_STARTED = true;

  const es = new EventSource("/events/task-events");
  window.__taskEventsES = es;

  function emit(kind, payload) {
    try { window.dispatchEvent(new CustomEvent("matilda.taskEvent", { detail: { kind, payload } })); } catch (_) {}
  }

  function normalize(kind, payload) {
    const p = payload || {};
    // Server event names: hello | heartbeat | task.event
    // task.event payload shape: { id, type, ts, taskId, runId, actor, meta, createdAt }
    if (kind === "hello" || kind === "heartbeat") return { kind, task: {}, id: null, raw: p };

    const meta = p.meta || {};
    const task = meta.task || p.task || {};
    const status = String(meta.status || task.status || "").toLowerCase();
    const id = p.taskId || meta.task_id || task.id || p.id || p.task_id || null;
    const type = String(p.type || p.kind || kind || "task.event");

    // Prefer canonical lifecycle type when present.
    if (type === "task.created") return { kind: "task.created", task: meta, id };
    if (type === "task.completed") return { kind: "task.completed", task: meta, id };
    if (type === "task.failed") return { kind: "task.failed", task: meta, id };

    // Otherwise derive from status.
    if (status in { "queued":1, "running":1, "started":1 }) return { kind: "task.progress", task: meta, id };
    if (status in { "completed":1, "done":1, "success":1 }) return { kind: "task.completed", task: meta, id };
    if (status in { "failed":1, "error":1 }) return { kind: "task.failed", task: meta, id };

    return { kind: "task.progress", task: meta, id, raw: p };
  }

  function line(kind, n) {
    const t = n.task || {};
    const id = n.id != null ? String(n.id) : (t.task_id ? String(t.task_id) : "?");
    const agent = (t.agent || t.target || "").toString().toUpperCase();
    const a = agent ? ` → ${agent}` : "";
    if (kind === "task.created") return `✨ task.created [${id}]${a}`;
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


  // Server uses named events (hello/heartbeat/task.event).
  ["hello", "heartbeat", "task.event"].forEach((k) => {
    es.addEventListener(k, (ev) => {
      try { push(k, JSON.parse(ev.data || "{}")); } catch (_) {}
    });
  });



  es.onerror = () => emit("task-events.error", { ts: Date.now() });
})();
