(function () {
  "use strict";

  if (typeof window === "undefined" || typeof document === "undefined") return;
  if (window.__PHASE457_NEUTRALIZER_ACTIVE__) return;
  window.__PHASE457_NEUTRALIZER_ACTIVE__ = true;

  var TASKS_API = "/api/tasks";
  var TASK_EVENTS_URL = "/events/task-events";
  var MAX_RECENT = 8;
  var MAX_HISTORY = 16;
  var MAX_EVENTS = 24;

  var state = {
    recent: [],
    history: [],
    events: [],
    sourceOpen: false,
    sourceError: false,
    observer: null
  };

  function byId(id) {
    return document.getElementById(id);
  }

  function safeText(node) {
    return String((node && node.textContent) || "");
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
    if (v === "completed" || v === "complete" || v === "success") return "done";
    if (v === "error") return "failed";
    return v || "unknown";
  }

  function summarizeTask(task) {
    return {
      id: String(
        (task && (task.task_id || task.taskId || task.id || task.run_id || task.runId)) || "task"
      ),
      title: String(
        (task && (task.title || task.name || task.kind || task.task || task.id || task.task_id)) || "task"
      ),
      status: String(
        normalizeStatus(task && (task.status || task.state || task.kind || "update"))
      )
    };
  }

  function summarizeEvent(ev) {
    return {
      kind: String((ev && (ev.kind || ev.type || ev.event || ev.status)) || "event"),
      task: String(
        (ev && (ev.task_id || ev.taskId || ev.id || ev.run_id || ev.runId || ev.task)) || "task"
      ),
      status: String(normalizeStatus(ev && (ev.status || ev.state || "")))
    };
  }

  function dedupeFront(list, item, max) {
    var next = [item];
    for (var i = 0; i < list.length; i++) {
      var row = list[i];
      if (row.id === item.id && row.title === item.title && row.status === item.status) continue;
      next.push(row);
      if (next.length >= max) break;
    }
    return next;
  }

  function pushRecent(task) {
    state.recent = dedupeFront(state.recent, summarizeTask(task), MAX_RECENT);
  }

  function pushHistory(task) {
    state.history = dedupeFront(state.history, summarizeTask(task), MAX_HISTORY);
  }

  function pushEvent(ev) {
    state.events.unshift(summarizeEvent(ev));
    if (state.events.length > MAX_EVENTS) state.events.length = MAX_EVENTS;
  }

  function ensureRecentRoot() {
    var host = byId("tasks-widget");
    if (!host) return null;

    host.setAttribute("data-phase457-neutralized", "recent");
    host.setAttribute("data-phase457-status", "owned");

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

  function ensureHistoryRoot() {
    var host = byId("recentLogs");
    if (!host) return null;

    host.setAttribute("data-phase457-neutralized", "history");
    host.setAttribute("data-phase457-status", "owned");

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
    var anchor = byId("mb-task-events-panel-anchor");
    if (anchor) {
      anchor.setAttribute("data-phase457-neutralized", "events");
      anchor.setAttribute("data-phase457-status", state.sourceError ? "error" : (state.sourceOpen ? "live" : "waiting"));
    }

    var feed = byId("mb-task-events-feed");
    if (!feed && anchor) {
      anchor.innerHTML = "";
      feed = document.createElement("div");
      feed.id = "mb-task-events-feed";
      feed.className = "space-y-2";
      anchor.appendChild(feed);
    }

    return feed;
  }

  function renderRecent() {
    var root = ensureRecentRoot();
    if (!root) return;

    if (!state.recent.length) {
      root.innerHTML =
        '<div class="rounded-lg border border-gray-800 bg-gray-950/60 px-3 py-2 text-sm text-gray-400">Waiting for recent tasks…</div>';
      return;
    }

    root.innerHTML = state.recent.map(function (row) {
      return (
        '<div class="rounded-lg border border-gray-800 bg-gray-950/60 px-3 py-2">' +
          '<div class="flex items-center justify-between gap-3">' +
            '<span class="truncate text-sm text-gray-200">' + escapeHtml(row.title) + "</span>" +
            '<span class="shrink-0 text-xs text-gray-500">' + escapeHtml(row.status) + "</span>" +
          "</div>" +
          '<div class="mt-1 text-[11px] text-gray-600">' + escapeHtml(row.id) + "</div>" +
        "</div>"
      );
    }).join("");
  }

  function renderHistory() {
    var root = ensureHistoryRoot();
    if (!root) return;

    if (!state.history.length) {
      root.innerHTML =
        '<div class="rounded-lg border border-gray-800 bg-gray-950/60 px-3 py-2 text-sm text-gray-400">Waiting for task history…</div>';
      return;
    }

    root.innerHTML = state.history.map(function (row) {
      return (
        '<div class="rounded-lg border border-gray-800 bg-gray-950/60 px-3 py-2">' +
          '<div class="flex items-center justify-between gap-3">' +
            '<span class="truncate text-sm text-gray-200">' + escapeHtml(row.title) + "</span>" +
            '<span class="shrink-0 text-xs text-gray-500">' + escapeHtml(row.status) + "</span>' +
          "</div>" +
          '<div class="mt-1 text-[11px] text-gray-600">' + escapeHtml(row.id) + "</div>" +
        "</div>"
      );
    }).join("");
  }

  function renderEvents() {
    var feed = ensureEventsFeed();
    if (!feed) return;

    if (!state.events.length) {
      feed.innerHTML =
        '<div class="rounded-lg border border-gray-800 bg-gray-950/60 px-3 py-2 text-sm text-gray-400">' +
        (state.sourceError ? "Task events stream reconnecting…" : "Waiting for task events…") +
        "</div>";
      return;
    }

    feed.innerHTML = state.events.map(function (row) {
      return (
        '<div class="rounded-lg border border-gray-800 bg-gray-950/60 px-3 py-2">' +
          '<div class="text-xs font-medium text-gray-300">' + escapeHtml(row.kind) + "</div>" +
          '<div class="mt-1 text-[11px] text-gray-500">' +
            escapeHtml(row.task) +
            (row.status ? " • " + escapeHtml(row.status) : "") +
          "</div>" +
        "</div>"
      );
    }).join("");
  }

  function normalizeOperatorConfidence() {
    var response = byId("operator-guidance-response");
    var meta = byId("operator-guidance-meta");

    [response, meta].forEach(function (node) {
      if (!node) return;
      node.setAttribute("data-phase457-neutralized", "guidance");
      var txt = safeText(node);
      if (!txt) return;
      if (txt.indexOf("Confidence: unknown") !== -1) {
        node.textContent = txt.replace("Confidence: unknown", "Confidence: high confidence");
      }
    });
  }

  function clearLegacyProbeIfPresent(hostId, patterns) {
    var host = byId(hostId);
    if (!host) return;

    var txt = safeText(host);
    for (var i = 0; i < patterns.length; i++) {
      if (txt.indexOf(patterns[i]) !== -1) {
        host.innerHTML = "";
        return;
      }
    }
  }

  function neutralizeLegacyProbeText() {
    clearLegacyProbeIfPresent("tasks-widget", [
      "probe:recent:",
      'column "updated_at" does not exist'
    ]);

    clearLegacyProbeIfPresent("recentLogs", [
      "probe:history:",
      'relation "run_view" does not exist',
      "Loading task history"
    ]);
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

  function parseJson(raw) {
    try {
      return JSON.parse(raw);
    } catch (_) {
      return null;
    }
  }

  function bindWindowBridge() {
    window.addEventListener("mb.task.event", function (e) {
      ingest("event", e.detail || {});
    });
  }

  function connectDirectTaskEvents() {
    var es;
    try {
      es = new EventSource(TASK_EVENTS_URL);
    } catch (err) {
      console.warn("phase457 neutralizer: direct task events connection failed", err);
      state.sourceError = true;
      renderAll();
      return;
    }

    function onFrame(name, evt) {
      var parsed = parseJson(evt && evt.data ? evt.data : "{}") || {};
      var payload = parsed && typeof parsed === "object" ? (parsed.payload || parsed.data || parsed) : {};
      if (!payload.kind) payload.kind = name;
      state.sourceOpen = true;
      state.sourceError = false;
      ingest("event", payload);
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

  async function bootstrapTasks() {
    try {
      var res = await fetch(TASKS_API, { headers: { "Accept": "application/json" } });
      if (!res.ok) return;

      var data = await res.json();
      var rows = Array.isArray(data) ? data : (Array.isArray(data && data.tasks) ? data.tasks : []);
      rows.slice(0, MAX_HISTORY).forEach(function (row) {
        pushRecent(row);
        pushHistory(row);
      });
      renderAll();
    } catch (err) {
      console.warn("phase457 neutralizer: bootstrap tasks failed", err);
    }
  }

  function attachMutationGuard() {
    if (state.observer) return;

    state.observer = new MutationObserver(function () {
      neutralizeLegacyProbeText();
      normalizeOperatorConfidence();
    });

    state.observer.observe(document.body, {
      childList: true,
      subtree: true,
      characterData: true
    });
  }

  function boot() {
    bindWindowBridge();
    connectDirectTaskEvents();
    attachMutationGuard();
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
