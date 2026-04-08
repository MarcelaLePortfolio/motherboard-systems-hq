(function () {
  if (typeof window === "undefined" || typeof document === "undefined") return;
  if (window.__PHASE457_RESTORE_TASK_PANELS_ACTIVE__) return;
  window.__PHASE457_RESTORE_TASK_PANELS_ACTIVE__ = true;

  var MAX_RECENT = 8;
  var MAX_HISTORY = 16;
  var MAX_EVENTS = 24;
  var TASKS_API = "/api/tasks";

  var state = {
    recent: [],
    history: [],
    events: [],
    sourceOpen: false,
    sourceError: false,
    es: null,
    bootstrapped: false
  };

  function byId(id) {
    return document.getElementById(id);
  }

  function escapeHtml(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function normalizeStatus(value) {
    var v = String(value || "").trim().toLowerCase();
    if (!v) return "unknown";
    if (v === "complete") return "completed";
    return v;
  }

  function normalizeTask(input) {
    var src = input && typeof input === "object" ? input : {};
    return {
      id: String(src.task_id || src.taskId || src.id || src.run_id || src.runId || ("task-" + Date.now())),
      title: String(src.title || src.name || src.task || src.task_id || src.taskId || "task"),
      status: normalizeStatus(src.status || src.state || src.kind || src.event || "queued"),
      updatedAt: src.updated_at || src.updatedAt || src.created_at || src.createdAt || src.ts || Date.now()
    };
  }

  function normalizeEvent(input) {
    var src = input && typeof input === "object" ? input : {};
    return {
      ts: src.ts || src.created_at || src.createdAt || Date.now(),
      kind: String(src.kind || src.event || src.type || src.status || "event"),
      task_id: String(src.task_id || src.taskId || src.id || "task"),
      status: String(src.status || src.state || ""),
      actor: String(src.actor || ""),
      run_id: String(src.run_id || src.runId || ""),
      message: String(src.message || src.msg || "")
    };
  }

  function upsertTask(list, task, max) {
    var existingIndex = list.findIndex(function (item) {
      return item.id === task.id;
    });

    if (existingIndex >= 0) {
      list[existingIndex] = Object.assign({}, list[existingIndex], task);
    } else {
      list.unshift(task);
    }

    list.sort(function (a, b) {
      return new Date(b.updatedAt).getTime() - new Date(a.updatedAt).getTime();
    });

    if (list.length > max) list.length = max;
  }

  function pushRecent(input) {
    upsertTask(state.recent, normalizeTask(input), MAX_RECENT);
  }

  function pushHistory(input) {
    upsertTask(state.history, normalizeTask(input), MAX_HISTORY);
  }

  function pushEvent(input) {
    state.events.unshift(normalizeEvent(input));
    if (state.events.length > MAX_EVENTS) state.events.length = MAX_EVENTS;
  }

  function renderRecent() {
    var el = byId("tasks-widget");
    if (!el) return;

    if (!state.recent.length) {
      el.innerHTML = '<div class="text-sm text-gray-500">No recent tasks yet.</div>';
      return;
    }

    el.innerHTML = state.recent.map(function (task) {
      return (
        '<div class="mb-2 rounded-lg border border-gray-700 bg-gray-900/60 px-3 py-2">' +
          '<div class="text-sm text-gray-200">' + escapeHtml(task.title) + '</div>' +
          '<div class="text-xs text-gray-500 mt-1">status: ' + escapeHtml(task.status) + '</div>' +
        '</div>'
      );
    }).join("");
  }

  function renderHistory() {
    var el = byId("recentLogs");
    if (!el) return;

    if (!state.history.length) {
      el.innerHTML = '<div class="text-sm text-gray-500">No task history yet.</div>';
      return;
    }

    el.innerHTML = state.history.map(function (task) {
      return (
        '<div class="mb-2 rounded-lg border border-gray-800 bg-black/20 px-3 py-2 text-sm text-gray-300">' +
          escapeHtml(task.title) + ' · ' + escapeHtml(task.status) +
        '</div>'
      );
    }).join("");
  }

  function renderEvents() {
    var anchor = byId("mb-task-events-panel-anchor");
    if (!anchor) return;

    var panel = byId("mb-task-events-panel");
    var feed = byId("mb-task-events-feed");

    if (!panel) {
      panel = document.createElement("div");
      panel.id = "mb-task-events-panel";
      panel.className = "rounded-lg border border-gray-700 bg-gray-900/60 p-3";
      anchor.innerHTML = "";
      anchor.appendChild(panel);
    }

    if (!feed) {
      feed = document.createElement("div");
      feed.id = "mb-task-events-feed";
      panel.innerHTML = "";
      panel.appendChild(feed);
    }

    if (!state.events.length) {
      feed.innerHTML =
        '<div class="text-sm text-gray-500">' +
        (state.sourceError ? "Task events stream reconnecting…" : "Waiting for task events…") +
        "</div>";
      return;
    }

    feed.innerHTML = state.events.map(function (eventRow) {
      return (
        '<div class="mb-2 rounded-lg border border-gray-800 bg-black/20 px-3 py-2">' +
          '<div class="text-xs text-gray-500">' + escapeHtml(eventRow.kind) + '</div>' +
          '<div class="text-sm text-gray-300 mt-1">' + escapeHtml(eventRow.task_id) + (eventRow.status ? " · " + escapeHtml(eventRow.status) : "") + '</div>' +
        '</div>'
      );
    }).join("");
  }

  function renderAll() {
    renderRecent();
    renderHistory();
    renderEvents();
  }

  function ingestTaskEvent(raw) {
    if (!raw || typeof raw !== "object") return;

    var task = normalizeTask(raw);
    pushRecent(task);
    pushHistory(task);

    var eventRow = normalizeEvent(raw);
    if (eventRow.kind === "unknown" && task.status) {
      eventRow.kind = task.status;
    }
    pushEvent(eventRow);

    renderAll();
  }

  function safeJsonParse(text) {
    try {
      return JSON.parse(text);
    } catch (_) {
      return null;
    }
  }

  function ingestFrame(name, rawData) {
    var parsed = typeof rawData === "string" ? safeJsonParse(rawData) : rawData;
    var payload = parsed && typeof parsed === "object"
      ? (parsed.payload || parsed.data || parsed)
      : {};

    if (Array.isArray(payload)) {
      payload.forEach(function (item) {
        ingestTaskEvent(item);
      });
      return;
    }

    if (payload && Array.isArray(payload.events)) {
      payload.events.forEach(function (item) {
        ingestTaskEvent(item);
      });
      return;
    }

    if (payload && typeof payload === "object") {
      if (!payload.kind && name) payload.kind = name;
      ingestTaskEvent(payload);
    }
  }

  function connectDirectTaskEvents() {
    if (state.es) return;

    try {
      state.es = new EventSource("/events/task-events");
    } catch (_) {
      state.sourceError = true;
      renderAll();
      return;
    }

    state.es.onopen = function () {
      state.sourceOpen = true;
      state.sourceError = false;
      renderAll();
    };

    state.es.onerror = function () {
      state.sourceError = true;
      renderAll();
    };

    state.es.onmessage = function (evt) {
      ingestFrame("message", evt && evt.data ? evt.data : "{}");
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
      state.es.addEventListener(name, function (evt) {
        ingestFrame(name, evt && evt.data ? evt.data : "{}");
      });
    });
  }

  function bootstrap() {
    if (state.bootstrapped) return;
    state.bootstrapped = true;

    fetch(TASKS_API, { headers: { Accept: "application/json" } })
      .then(function (res) {
        if (!res.ok) throw new Error("tasks bootstrap failed");
        return res.json();
      })
      .then(function (data) {
        var rows = Array.isArray(data) ? data : (Array.isArray(data.tasks) ? data.tasks : []);
        rows.slice(0, MAX_HISTORY).forEach(function (row) {
          pushRecent(row);
          pushHistory(row);
        });
        renderAll();
      })
      .catch(function () {
        renderAll();
      });
  }

  window.addEventListener("mb.task.event", function (e) {
    ingestTaskEvent((e && e.detail) || {});
  });

  function boot() {
    renderAll();
    bootstrap();
    connectDirectTaskEvents();
    setInterval(renderAll, 4000);
    console.log("phase457 panels stable");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
