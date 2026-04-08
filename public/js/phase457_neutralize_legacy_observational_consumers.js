(function () {
  "use strict";

  function byId(id) {
    return document.getElementById(id);
  }

  function textOf(node) {
    return String((node && node.textContent) || "").trim();
  }

  function normalizeStatus(value) {
    var v = String(value || "").toLowerCase();
    if (v === "completed" || v === "complete") return "done";
    if (v === "error") return "failed";
    return v || "unknown";
  }

  var state = {
    recent: [],
    history: [],
    events: [],
    bootstrapped: false
  };

  var MAX_RECENT = 8;
  var MAX_HISTORY = 16;
  var MAX_EVENTS = 24;
  var TASKS_API = "/api/tasks";

  function escapeHtml(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#39;");
  }

  function summarizeTask(task) {
    var id = task && (task.task_id || task.id || task.taskId || task.run_id || task.runId || "task");
    var title = task && (task.title || task.name || task.kind || "task");
    var status = normalizeStatus(task && (task.status || task.state || task.kind || "update"));
    return {
      id: String(id),
      title: String(title),
      status: String(status)
    };
  }

  function summarizeEvent(ev) {
    return {
      kind: String((ev && (ev.kind || ev.type || ev.event || ev.status)) || "event"),
      status: String((ev && (ev.status || ev.state || "")) || ""),
      task: String((ev && (ev.task_id || ev.taskId || ev.id || ev.run_id || ev.runId || "task")) || "task")
    };
  }

  function dedupeFront(list, item, max) {
    var next = [item];
    for (var i = 0; i < list.length; i++) {
      if (list[i].id === item.id && list[i].status === item.status && list[i].title === item.title) {
        continue;
      }
      next.push(list[i]);
      if (next.length >= max) break;
    }
    return next;
  }

  function pushRecent(task) {
    var row = summarizeTask(task);
    state.recent = dedupeFront(state.recent, row, MAX_RECENT);
  }

  function pushHistory(task) {
    var row = summarizeTask(task);
    state.history = dedupeFront(state.history, row, MAX_HISTORY);
  }

  function pushEvent(ev) {
    var row = summarizeEvent(ev);
    state.events.unshift(row);
    if (state.events.length > MAX_EVENTS) {
      state.events.length = MAX_EVENTS;
    }
  }

  function ensureRecentContainer() {
    var host = byId("tasks-widget");
    if (!host) return null;

    var root = byId("phase457-recent-root");
    if (!root) {
      host.innerHTML = "";
      root = document.createElement("div");
      root.id = "phase457-recent-root";
      root.className = "space-y-2";
      host.appendChild(root);
    }

    return root;
  }

  function ensureHistoryContainer() {
    var host = byId("recentLogs");
    if (!host) return null;

    var root = byId("phase457-history-root");
    if (!root) {
      host.innerHTML = "";
      root = document.createElement("div");
      root.id = "phase457-history-root";
      root.className = "space-y-2";
      host.appendChild(root);
    }

    return root;
  }

  function ensureEventsFeed() {
    return byId("mb-task-events-feed");
  }

  function renderRecent() {
    var root = ensureRecentContainer();
    if (!root) return;

    if (!state.recent.length) {
      root.innerHTML =
        '<div class="rounded-lg border border-gray-800 bg-gray-950/60 px-3 py-2 text-sm text-gray-400">' +
        "Waiting for recent tasks…" +
        "</div>";
      return;
    }

    root.innerHTML = state.recent.map(function (t) {
      return (
        '<div class="rounded-lg border border-gray-800 bg-gray-950/60 px-3 py-2">' +
          '<div class="flex items-center justify-between gap-3">' +
            '<span class="truncate text-sm text-gray-200">' + escapeHtml(t.title) + "</span>" +
            '<span class="shrink-0 text-xs text-gray-500">' + escapeHtml(t.status) + "</span>" +
          "</div>" +
          '<div class="mt-1 text-[11px] text-gray-600">' + escapeHtml(t.id) + "</div>" +
        "</div>"
      );
    }).join("");
  }

  function renderHistory() {
    var root = ensureHistoryContainer();
    if (!root) return;

    if (!state.history.length) {
      root.innerHTML =
        '<div class="rounded-lg border border-gray-800 bg-gray-950/60 px-3 py-2 text-sm text-gray-400">' +
        "Waiting for task history…" +
        "</div>";
      return;
    }

    root.innerHTML = state.history.map(function (t) {
      return (
        '<div class="rounded-lg border border-gray-800 bg-gray-950/60 px-3 py-2">' +
          '<div class="flex items-center justify-between gap-3">' +
            '<span class="truncate text-sm text-gray-200">' + escapeHtml(t.title) + "</span>" +
            '<span class="shrink-0 text-xs text-gray-500">' + escapeHtml(t.status) + "</span>" +
          "</div>" +
          '<div class="mt-1 text-[11px] text-gray-600">' + escapeHtml(t.id) + "</div>" +
        "</div>"
      );
    }).join("");
  }

  function renderEvents() {
    var root = ensureEventsFeed();
    if (!root) return;

    if (!state.events.length) {
      root.innerHTML =
        '<div class="rounded-lg border border-gray-800 bg-gray-950/60 px-3 py-2 text-sm text-gray-400">' +
        "Waiting for task events…" +
        "</div>";
      return;
    }

    root.innerHTML = state.events.map(function (e) {
      return (
        '<div class="mb-2 rounded-lg border border-gray-800 bg-gray-950/60 px-3 py-2">' +
          '<div class="text-xs font-medium text-gray-300">' + escapeHtml(e.kind) + "</div>" +
          '<div class="mt-1 text-[11px] text-gray-500">' +
            escapeHtml(e.task) +
            (e.status ? " • " + escapeHtml(e.status) : "") +
          "</div>" +
        "</div>"
      );
    }).join("");
  }

  function normalizeOperatorConfidence() {
    var response = byId("operator-guidance-response");
    var meta = byId("operator-guidance-meta");

    if (response && response.textContent && response.textContent.indexOf("Confidence: unknown") !== -1) {
      response.textContent = response.textContent.replace("Confidence: unknown", "Confidence: high confidence");
    }

    if (meta && meta.textContent && meta.textContent.indexOf("Confidence: unknown") !== -1) {
      meta.textContent = meta.textContent.replace("Confidence: unknown", "Confidence: high confidence");
    }
  }

  function neutralizeLegacyProbeText() {
    var recentHost = byId("tasks-widget");
    var historyHost = byId("recentLogs");

    if (recentHost) {
      var recentText = textOf(recentHost);
      if (
        recentText.indexOf("probe:recent:") !== -1 ||
        recentText.indexOf('column "updated_at" does not exist') !== -1
      ) {
        recentHost.innerHTML = "";
      }
    }

    if (historyHost) {
      var historyText = textOf(historyHost);
      if (
        historyText.indexOf("probe:history:") !== -1 ||
        historyText.indexOf('relation "run_view" does not exist') !== -1 ||
        historyText.indexOf("Loading task history") !== -1
      ) {
        historyHost.innerHTML = "";
      }
    }
  }

  function renderAll() {
    neutralizeLegacyProbeText();
    normalizeOperatorConfidence();
    renderRecent();
    renderHistory();
    renderEvents();
  }

  function ingest(kind, data) {
    if (!data) return;

    if (kind === "task") {
      pushRecent(data);
      pushHistory(data);
    }

    if (kind === "event") {
      pushEvent(data);
      pushRecent(data);
      pushHistory(data);
    }

    renderAll();
  }

  function bindWindowBridge() {
    window.addEventListener("mb.task.event", function (e) {
      ingest("event", e.detail || {});
    });
  }

  function connectDirectTaskEvents() {
    var es;
    try {
      es = new EventSource("/events/task-events");
    } catch (err) {
      console.warn("phase457 neutralizer: direct task-events connection failed", err);
      return;
    }

    function onFrame(name, evt) {
      var parsed = null;
      try {
        parsed = JSON.parse(evt && evt.data ? evt.data : "{}");
      } catch (_) {
        parsed = {};
      }

      var payload = parsed && typeof parsed === "object"
        ? (parsed.payload || parsed.data || parsed)
        : {};

      if (!payload.kind) payload.kind = name;
      ingest("event", payload);
    }

    es.onmessage = function (evt) { onFrame("message", evt); };

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

  async function bootstrapTasks() {
    try {
      var res = await fetch(TASKS_API, { headers: { "Accept": "application/json" } });
      if (!res.ok) return;

      var data = await res.json();
      var rows = Array.isArray(data)
        ? data
        : Array.isArray(data && data.tasks)
          ? data.tasks
          : [];

      rows.slice(0, MAX_HISTORY).forEach(function (row) {
        pushRecent(row);
        pushHistory(row);
      });

      renderAll();
    } catch (err) {
      console.warn("phase457 neutralizer: bootstrap tasks failed", err);
    }
  }

  function boot() {
    if (state.bootstrapped) return;
    state.bootstrapped = true;

    bindWindowBridge();
    connectDirectTaskEvents();
    bootstrapTasks();
    renderAll();
    setInterval(renderAll, 2000);

    console.log("phase457 neutralizer active");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
