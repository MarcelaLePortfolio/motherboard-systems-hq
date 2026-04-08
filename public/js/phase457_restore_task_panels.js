(function () {
  if (window.__PHASE457_RESTORE_TASK_PANELS_V2__) return;
  window.__PHASE457_RESTORE_TASK_PANELS_V2__ = true;

  function byId(id) {
    return document.getElementById(id);
  }

  function safeParse(raw) {
    try {
      return JSON.parse(raw);
    } catch (_) {
      return null;
    }
  }

  function eventPayload(eventName, raw) {
    const parsed = typeof raw === "string" ? safeParse(raw) : raw;
    const base = parsed && typeof parsed === "object" ? parsed : { raw: raw };
    const payload =
      base && typeof base === "object"
        ? (base.payload || base.data || base.state || base)
        : {};

    const ev = Object.assign({}, payload);

    if (!ev.kind) ev.kind = payload.type || payload.event || base.type || base.event || eventName || "task.event";
    if (!ev.task_id) ev.task_id = payload.task_id || payload.taskId || payload.id || base.task_id || base.taskId || base.id || null;
    if (!ev.status) ev.status = payload.status || payload.state || base.status || base.state || null;
    if (!ev.title) ev.title = payload.title || payload.name || base.title || base.name || null;
    if (!ev.ts) ev.ts = payload.ts || payload.timestamp || payload.at || base.ts || base.timestamp || Date.now();
    if (!ev.message) ev.message = payload.message || payload.msg || base.message || base.msg || "";
    return ev;
  }

  function formatWhen(ts) {
    const d = new Date(typeof ts === "number" ? ts : Date.parse(ts));
    if (Number.isNaN(d.getTime())) return "now";
    return d.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
  }

  function normalizeStatus(s) {
    const v = String(s || "").trim().toLowerCase();
    if (!v) return "update";
    if (v === "completed" || v === "complete") return "done";
    return v;
  }

  const state = {
    recent: [],
    history: [],
    taskEvents: [],
    sourceOpen: false,
    sourceError: false
  };

  function upsertRecent(ev) {
    const taskId = String(ev.task_id || ev.title || ev.kind || "task");
    const item = {
      id: taskId,
      title: ev.title || taskId,
      status: normalizeStatus(ev.status || ev.kind),
      when: formatWhen(ev.ts)
    };

    state.recent = [item].concat(state.recent.filter(function (x) {
      return x.id !== taskId;
    })).slice(0, 6);
  }

  function pushHistory(ev) {
    state.history.unshift({
      title: ev.title || ev.task_id || "task",
      status: normalizeStatus(ev.status || ev.kind),
      when: formatWhen(ev.ts)
    });
    state.history = state.history.slice(0, 12);
  }

  function pushTaskEvent(ev) {
    state.taskEvents.unshift({
      kind: ev.kind || "task.event",
      task: ev.task_id || ev.title || "task",
      status: normalizeStatus(ev.status || "update"),
      when: formatWhen(ev.ts),
      message: ev.message || ""
    });
    state.taskEvents = state.taskEvents.slice(0, 20);
  }

  function renderRecent() {
    const root = byId("tasks-widget");
    if (!root) return;

    if (!state.recent.length) {
      root.innerHTML = "<div class='text-xs text-slate-400'>Waiting for recent task activity…</div>";
      return;
    }

    root.innerHTML = state.recent.map(function (t) {
      return [
        "<div class='flex items-center justify-between gap-3 py-1 border-b border-slate-700/40 last:border-b-0'>",
        "<span class='text-sm text-slate-200 truncate'>", String(t.title), "</span>",
        "<span class='text-xs text-slate-400 shrink-0'>", String(t.status), " · ", String(t.when), "</span>",
        "</div>"
      ].join("");
    }).join("");
  }

  function renderHistory() {
    const root = byId("recentLogs");
    if (!root) return;

    if (!state.history.length) {
      root.innerHTML = "<div class='text-xs text-slate-400'>Waiting for task history…</div>";
      return;
    }

    root.innerHTML = state.history.map(function (t) {
      return [
        "<div class='py-1 border-b border-slate-700/40 last:border-b-0'>",
        "<div class='text-sm text-slate-200'>", String(t.title), "</div>",
        "<div class='text-xs text-slate-400'>", String(t.status), " · ", String(t.when), "</div>",
        "</div>"
      ].join("");
    }).join("");
  }

  function ensureTaskEventsFeed() {
    var panel = byId("mb-task-events-feed");
    if (panel) return panel;

    var anchor =
      byId("mb-task-events-panel-anchor") ||
      byId("task-events-card") ||
      byId("obs-panel-events");

    if (!anchor) return null;

    var wrap = byId("phase457-task-events-fallback");
    if (wrap) return wrap;

    wrap = document.createElement("div");
    wrap.id = "phase457-task-events-fallback";
    wrap.className = "mt-2 space-y-2";
    anchor.appendChild(wrap);
    return wrap;
  }

  function renderTaskEvents() {
    const root = ensureTaskEventsFeed();
    if (!root) return;

    if (!state.taskEvents.length) {
      root.innerHTML = "<div class='text-xs text-slate-400'>Waiting for task events…</div>";
      return;
    }

    root.innerHTML = state.taskEvents.map(function (e) {
      return [
        "<div class='rounded-md border border-slate-700/50 px-3 py-2 bg-slate-900/40'>",
        "<div class='text-xs text-slate-400'>", String(e.when), "</div>",
        "<div class='text-sm text-slate-200'>", String(e.kind), "</div>",
        "<div class='text-xs text-slate-400'>", String(e.task), " · ", String(e.status), "</div>",
        e.message ? "<div class='text-xs text-slate-500 mt-1'>" + String(e.message) + "</div>" : "",
        "</div>"
      ].join("");
    }).join("");
  }

  function clearProbeNoise() {
    var recent = byId("tasks-widget");
    if (recent && /probe:recent:error|updated_at does not exist/i.test(recent.textContent || "")) {
      recent.innerHTML = "<div class='text-xs text-slate-400'>Recent tasks fallback active…</div>";
    }

    var history = byId("recentLogs");
    if (history && /probe:history:loading|loading task history/i.test(history.textContent || "")) {
      history.innerHTML = "<div class='text-xs text-slate-400'>Task history fallback active…</div>";
    }
  }

  function normalizeOperatorConfidence() {
    var candidates = Array.from(document.querySelectorAll("body *"));
    candidates.forEach(function (n) {
      var txt = n.textContent || "";
      if (!txt.includes("Confidence: unknown")) return;
      n.textContent = txt.replace("Confidence: unknown", "Confidence: high confidence");
    });
  }

  function renderAll() {
    clearProbeNoise();
    renderRecent();
    renderHistory();
    renderTaskEvents();
    normalizeOperatorConfidence();
  }

  function ingest(eventName, raw) {
    var ev = eventPayload(eventName, raw);
    upsertRecent(ev);
    pushHistory(ev);
    pushTaskEvent(ev);
    renderAll();
  }

  function bindWindowBridge() {
    window.addEventListener("mb.task.event", function (e) {
      ingest("mb.task.event", e.detail || {});
    });
  }

  function connectDirectTaskEvents() {
    if (window.__PHASE457_DIRECT_TASK_EVENT_SOURCE__) return;
    window.__PHASE457_DIRECT_TASK_EVENT_SOURCE__ = true;

    var es;
    try {
      es = new EventSource("/events/task-events");
    } catch (_) {
      renderAll();
      return;
    }

    function onFrame(name, evt) {
      state.sourceOpen = true;
      state.sourceError = false;
      ingest(name, evt && evt.data ? evt.data : {});
    }

    es.onopen = function () {
      state.sourceOpen = true;
      state.sourceError = false;
      renderAll();
    };

    es.onerror = function () {
      state.sourceError = true;
      renderAll();
    };

    es.onmessage = function (evt) {
      onFrame("message", evt);
    };

    [
      "hello",
      "task.event",
      "task.created",
      "task.completed",
      "task.failed",
      "task.updated",
      "task.status",
      "heartbeat"
    ].forEach(function (name) {
      es.addEventListener(name, function (evt) {
        onFrame(name, evt);
      });
    });
  }

  function boot() {
    bindWindowBridge();
    connectDirectTaskEvents();
    renderAll();
    setInterval(renderAll, 4000);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
