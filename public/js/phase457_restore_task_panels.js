(function () {
  if (typeof window === "undefined" || typeof document === "undefined") return;
  if (window.__PHASE457_RESTORE_TASK_PANELS_ACTIVE__) return;
  window.__PHASE457_RESTORE_TASK_PANELS_ACTIVE__ = true;

  var MAX_RECENT = 8;
  var MAX_HISTORY = 12;
  var MAX_EVENTS = 20;
  var TASKS_API = "/api/tasks";

  var state = {
    recent: [],
    history: [],
    events: [],
    bootstrapped: false,
    sourceOpen: false,
    sourceError: false,
    es: null
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
    var v = String(value == null ? "" : value).trim().toLowerCase();
    if (!v) return "unknown";
    if (v === "complete" || v === "completed" || v === "success") return "done";
    if (v === "pending") return "queued";
    return v;
  }

  function taskLabel(task) {
    return (
      task.title ||
      task.name ||
      task.task_id ||
      task.taskId ||
      task.id ||
      "task"
    );
  }

  function taskStatus(task) {
    return normalizeStatus(
      task.status ||
      task.state ||
      task.kind ||
      task.event ||
      "unknown"
    );
  }

  function eventKind(ev) {
    return (
      ev.kind ||
      ev.type ||
      ev.event ||
      ev.status ||
      "event"
    );
  }

  function dedupeBy(list, keyFn) {
    var seen = Object.create(null);
    return list.filter(function (item) {
      var key = keyFn(item);
      if (seen[key]) return false;
      seen[key] = true;
      return true;
    });
  }

  function pushRecent(task) {
    state.recent.unshift({
      label: taskLabel(task),
      status: taskStatus(task)
    });
    state.recent = dedupeBy(state.recent, function (row) {
      return row.label + "|" + row.status;
    }).slice(0, MAX_RECENT);
  }

  function pushHistory(task) {
    state.history.unshift({
      label: taskLabel(task),
      status: taskStatus(task)
    });
    state.history = dedupeBy(state.history, function (row) {
      return row.label + "|" + row.status;
    }).slice(0, MAX_HISTORY);
  }

  function pushEvent(ev) {
    state.events.unshift({
      kind: eventKind(ev),
      detail:
        ev.task_id ||
        ev.taskId ||
        ev.id ||
        ev.run_id ||
        ev.runId ||
        ""
    });
    state.events = dedupeBy(state.events, function (row) {
      return row.kind + "|" + row.detail;
    }).slice(0, MAX_EVENTS);
  }

  function renderRecent() {
    var host = byId("tasks-widget");
    if (!host) return;

    if (!state.recent.length) {
      host.innerHTML =
        '<div class="text-sm text-gray-500">Waiting for recent tasks…</div>';
      return;
    }

    host.innerHTML = state.recent.map(function (row) {
      return (
        '<div class="flex items-center justify-between gap-3 py-1 text-sm">' +
          '<span class="truncate text-gray-200">' + escapeHtml(row.label) + '</span>' +
          '<span class="shrink-0 text-xs text-gray-500">' + escapeHtml(row.status) + '</span>' +
        "</div>"
      );
    }).join("");
  }

  function renderHistory() {
    var host = byId("recentLogs");
    if (!host) return;

    if (!state.history.length) {
      host.innerHTML =
        '<div class="text-sm text-gray-500">Waiting for task history…</div>';
      return;
    }

    host.innerHTML = state.history.map(function (row) {
      return (
        '<div class="py-1 text-sm text-gray-300">' +
          '<span class="text-gray-200">' + escapeHtml(row.label) + '</span>' +
          '<span class="text-gray-500"> · ' + escapeHtml(row.status) + "</span>" +
        "</div>"
      );
    }).join("");
  }

  function renderEvents() {
    var anchor = byId("mb-task-events-panel-anchor");
    if (!anchor) return;

    if (!state.events.length) return;

    var existingPanel = byId("mb-task-events-panel");
    if (existingPanel) return;

    anchor.innerHTML = state.events.map(function (row) {
      return (
        '<div class="mb-1 text-xs text-gray-500">' +
          escapeHtml(row.kind + (row.detail ? " · " + row.detail : "")) +
        "</div>"
      );
    }).join("");
  }

  function renderAll() {
    renderRecent();
    renderHistory();
    renderEvents();
  }

  function ingestEventPayload(payload) {
    if (!payload || typeof payload !== "object") return;
    pushRecent(payload);
    pushHistory(payload);
    pushEvent(payload);
    renderAll();
  }

  function bindWindowBridge() {
    window.addEventListener("mb.task.event", function (e) {
      ingestEventPayload(e.detail || {});
    });
  }

  function ingestFrame(eventName, raw) {
    var data = raw;
    if (typeof raw === "string") {
      try {
        data = JSON.parse(raw);
      } catch (_) {
        data = { kind: eventName };
      }
    }

    if (Array.isArray(data)) {
      data.forEach(ingestEventPayload);
      return;
    }

    if (data && typeof data === "object" && Array.isArray(data.events)) {
      data.events.forEach(ingestEventPayload);
      return;
    }

    if (data && typeof data === "object" && data.payload && typeof data.payload === "object") {
      ingestEventPayload(data.payload);
      return;
    }

    ingestEventPayload(data || { kind: eventName });
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
      ingestFrame("message", evt && evt.data ? evt.data : {});
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
        ingestFrame(name, evt && evt.data ? evt.data : {});
      });
    });
  }

  function bootstrapFromApi() {
    if (state.bootstrapped) return;
    state.bootstrapped = true;

    fetch(TASKS_API)
      .then(function (r) {
        if (!r.ok) throw new Error("tasks bootstrap failed");
        return r.json();
      })
      .then(function (data) {
        if (!Array.isArray(data)) return;
        data.slice(0, MAX_HISTORY).forEach(function (task) {
          pushRecent(task);
          pushHistory(task);
        });
        renderAll();
      })
      .catch(function () {});
  }

  function boot() {
    bindWindowBridge();
    bootstrapFromApi();
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
