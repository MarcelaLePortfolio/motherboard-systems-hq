/*
PHASE 65B TELEMETRY HYDRATION
Running Tasks Metric

STRICT RULES:
DATA ONLY CHANGE
NO LAYOUT TOUCH
NO DOM STRUCTURE MUTATION
NO CONTAINER INSERTION
*/

(function () {
  const ACTIVE_EVENT_TYPES = new Set([
    "task.created",
    "task.started",
    "task.running",
  ]);

  const TERMINAL_EVENT_TYPES = new Set([
    "task.completed",
    "task.failed",
    "task.cancelled",
  ]);

  const activeTasks = new Set();

  function getMetricNode() {
    return document.getElementById("metric-tasks");
  }

  function render() {
    const node = getMetricNode();
    if (!node) return;
    node.textContent = String(activeTasks.size);
  }

  function getEventType(payload) {
    return payload?.type || payload?.event || payload?.name || "";
  }

  function getTaskId(payload) {
    return payload?.task_id || payload?.taskId || payload?.id || "";
  }

  function processPayload(payload) {
    const type = getEventType(payload);
    const taskId = getTaskId(payload);

    if (!type || !taskId) return;

    if (ACTIVE_EVENT_TYPES.has(type)) {
      activeTasks.add(taskId);
    }

    if (TERMINAL_EVENT_TYPES.has(type)) {
      activeTasks.delete(taskId);
    }

    render();
  }

  function attachToTaskEventsSource(source) {
    if (!source || source.__phase65bRunningTasksBound) return;

    source.__phase65bRunningTasksBound = true;

    source.addEventListener("message", function (e) {
      try {
        processPayload(JSON.parse(e.data));
      } catch (err) {
        console.warn("running_tasks_metric parse error");
      }
    });
  }

  function patchEventSource() {
    if (window.__phase65bRunningTasksEventSourcePatched) return;

    const NativeEventSource = window.EventSource;
    if (typeof NativeEventSource !== "function") {
      render();
      return;
    }

    function PatchedEventSource(url, config) {
      const source = new NativeEventSource(url, config);

      try {
        const urlText = String(url || "");
        if (urlText.includes("/events/task-events")) {
          attachToTaskEventsSource(source);
        }
      } catch (err) {
        console.warn("running_tasks_metric attach error");
      }

      return source;
    }

    PatchedEventSource.prototype = NativeEventSource.prototype;
    window.EventSource = PatchedEventSource;
    window.__phase65bRunningTasksEventSourcePatched = true;
  }

  function bootstrap() {
    patchEventSource();
    render();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", bootstrap);
  } else {
    bootstrap();
  }
})();
