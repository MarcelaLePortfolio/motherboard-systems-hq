/*
PHASE 65B TELEMETRY HYDRATION
Running Tasks Metric
Telemetry now sole writer.
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

    if (window.__phase65bMetricWrite) {
      window.__phase65bMetricWrite(() => {
        node.textContent = String(activeTasks.size);
      });
    } else {
      node.textContent = String(activeTasks.size);
    }
  }

  function processPayload(payload) {
    const type = payload?.type || payload?.event || payload?.name;
    const id = payload?.task_id || payload?.taskId || payload?.id;

    if (!type || !id) return;

    if (ACTIVE_EVENT_TYPES.has(type)) {
      activeTasks.add(id);
    }

    if (TERMINAL_EVENT_TYPES.has(type)) {
      activeTasks.delete(id);
    }

    render();
  }

  function attach(source) {
    if (!source || source.__phase65bBound) return;

    source.__phase65bBound = true;

    source.addEventListener("message", (e) => {
      try {
        processPayload(JSON.parse(e.data));
      } catch {
        console.warn("running_tasks_metric parse error");
      }
    });
  }

  function patchEventSource() {
    if (window.__phase65bPatched) return;

    const Native = window.EventSource;
    if (typeof Native !== "function") return;

    function Wrapped(url, config) {
      const es = new Native(url, config);

      try {
        if (String(url).includes("/events/task-events")) {
          attach(es);
        }
      } catch {}

      return es;
    }

    Wrapped.prototype = Native.prototype;
    window.EventSource = Wrapped;
    window.__phase65bPatched = true;
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
