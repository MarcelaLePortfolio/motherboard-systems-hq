(function () {
  if (window.__PHASE23_TASK_EVENTS_BRIDGE_STARTED) return;
  window.__PHASE23_TASK_EVENTS_BRIDGE_STARTED = true;

  if (!window.EventSource) return;

  const es = new EventSource("/events/task-events");
  window.__taskEventsES = es;

  function emit(kind, payload) {
    try {
      window.dispatchEvent(
        new CustomEvent("matilda.taskEvent", { detail: { kind, payload } })
      );
    } catch (_) {}
  }

  function normalize(kind, payload) {
    const p = payload || {};

    // Server event names: hello | heartbeat | task.event
    // task.event payload shape: { id, type, ts, taskId, runId, actor, meta, createdAt }
    if (kind === "hello" || kind === "heartbeat") return { kind, task: {}, id: null, raw: p };

    const meta = p.meta || {};
    const task = meta.task || p.task || {};

    // Merge meta + top-level fields (so line() can show actor/run/source/etc)
    const merged = Object.assign({}, meta);

    // Prefer explicit meta; fall back to nested task + top-level
    if (merged.status == null && task.status != null) merged.status = task.status;
    if (merged.agent == null && (task.agent || task.target)) merged.agent = task.agent || task.target;
    if (merged.target == null && task.target) merged.target = task.target;

    if (merged.source == null && p.source != null) merged.source = p.source;
    if (merged.actor == null && p.actor != null) merged.actor = p.actor;

    if (merged.runId == null && p.runId != null) merged.runId = p.runId;
    if (merged.run_id == null && p.run_id != null) merged.run_id = p.run_id;

    if (merged.trace_id == null && (p.trace_id != null || task.trace_id != null)) {
      merged.trace_id = p.trace_id != null ? p.trace_id : task.trace_id;
    }

    const status = String(merged.status || "").toLowerCase();
    // IMPORTANT:
    // For server SSE event "task.event", payload `p.id` is the *task_events row id*,
    // not the task id from the `tasks` table. Never fall back to p.id here.
    const id = p.taskId || merged.task_id || task.id || p.task_id || null;
    const type = String(p.type || p.kind || kind || "task.event");

    // Prefer canonical lifecycle type when present.
    if (type === "task.created") return { kind: "task.created", task: merged, id };
    if (type === "task.completed") return { kind: "task.completed", task: merged, id };
    if (type === "task.failed") return { kind: "task.failed", task: merged, id };

    // Otherwise derive from status.
    if (status in { queued: 1, running: 1, started: 1 }) return { kind: "task.progress", task: merged, id };
    if (status in { completed: 1, done: 1, success: 1 }) return { kind: "task.completed", task: merged, id };
    if (status in { failed: 1, error: 1 }) return { kind: "task.failed", task: merged, id };

    return { kind: "task.progress", task: merged, id, raw: p };
  }

  function line(kind, n) {
    const t = n.task || {};
    const id = n.id != null ? String(n.id) : (t.task_id ? String(t.task_id) : "?");

    const agent = String(t.agent || t.target || "").toUpperCase();
    const a = agent ? ` → ${agent}` : "";

    const status = String(t.status || "").toLowerCase();
    const actor  = t.actor ? String(t.actor) : "";
    const source = t.source ? String(t.source) : "";
    const runId  = t.runId ? String(t.runId) : (t.run_id ? String(t.run_id) : "");
    const trace  = t.trace_id ? String(t.trace_id) : "";

    const bits = [];
    if (status) bits.push(`st=${status}`);
    if (actor) bits.push(`actor=${actor}`);
    if (source) bits.push(`src=${source}`);
    if (runId) bits.push(`run=${runId}`);
    if (trace) bits.push(`trace=${trace}`);

    const tail = bits.length ? ` {${bits.join(" ")}}` : "";

    if (kind === "task.created")   return `✨ task.created [${id}]${a}${tail}`;
    if (kind === "task.completed") return `🎉 task.completed [${id}]${a}${tail}`;
    if (kind === "task.failed")    return `❌ task.failed [${id}]${a}${tail}`;
    if (kind === "task.progress")  return `⏳ task.${(t.status || "update")} [${id}]${a}${tail}`;
    if (kind === "heartbeat") return null;
    if (kind === "hello") return null;

    return `ℹ️ ${kind} [${id}]${a}${tail}`;
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
