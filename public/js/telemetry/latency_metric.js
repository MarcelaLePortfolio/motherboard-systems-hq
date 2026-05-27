/*
PHASE 65C TELEMETRY HYDRATION
Latency Metric
Telemetry now sole writer.
*/

(function () {
  const RUNNING_EVENT_TYPES = new Set([
    "task.created",
    "task.queued",
    "task.leased",
    "task.started",
    "task.running",
    "task.in_progress",
    "task.delegated",
    "task.retrying",
    "created",
    "queued",
    "leased",
    "started",
    "running",
    "in_progress",
    "delegated",
    "retrying",
  ]);

  const TERMINAL_EVENT_TYPES = new Set([
    "task.completed",
    "task.complete",
    "task.done",
    "task.success",
    "task.failed",
    "task.error",
    "task.cancelled",
    "task.canceled",
    "task.timed_out",
    "task.timeout",
    "task.terminated",
    "task.aborted",
    "completed",
    "complete",
    "done",
    "success",
    "failed",
    "error",
    "cancelled",
    "canceled",
    "timed_out",
    "timeout",
    "terminated",
    "aborted",
  ]);

  const taskStartTimes = new Map();
  const seenTerminalEvents = new Set();
  const recentDurationsMs = [];
  const maxSamples = 50;

  function getMetricNode() {
    return document.getElementById("metric-latency");
  }

  function formatLatency(ms) {
    if (!Number.isFinite(ms) || ms <= 0) return "—";
    if (ms < 1000) return `${Math.round(ms)}ms`;
    const seconds = ms / 1000;
    if (seconds < 60) return `${seconds.toFixed(seconds >= 10 ? 0 : 1)}s`;
    const minutes = seconds / 60;
    return `${minutes.toFixed(minutes >= 10 ? 0 : 1)}m`;
  }

  function render() {
    const node = getMetricNode();
    if (!node) return;

    const value = !recentDurationsMs.length
      ? "—"
      : formatLatency(
          recentDurationsMs.reduce((sum, value) => sum + value, 0) /
            recentDurationsMs.length
        );

    if (window.__phase65bMetricWrite) {
      window.__phase65bMetricWrite(() => {
        node.textContent = value;
      });
    } else {
      node.textContent = value;
    }
  }

  function getEventType(payload) {
    return String(
      payload?.type ||
        payload?.event ||
        payload?.name ||
        payload?.status ||
        payload?.state ||
        ""
    )
      .trim()
      .toLowerCase();
  }

  function getTaskId(payload) {
    return String(
      payload?.task_id ??
        payload?.taskId ??
        payload?.id ??
        payload?.data?.task_id ??
        payload?.data?.taskId ??
        ""
    ).trim();
  }

  function toMs(raw) {
    if (typeof raw === "number" && Number.isFinite(raw)) {
      return raw > 1e12 ? raw : raw * 1000;
    }

    if (typeof raw === "string" && raw.trim()) {
      const asNum = Number(raw);
      if (Number.isFinite(asNum)) return asNum > 1e12 ? asNum : asNum * 1000;
      const parsed = Date.parse(raw);
      if (Number.isFinite(parsed)) return parsed;
    }

    return Date.now();
  }

  function getEventTs(payload) {
    return toMs(
      payload?.ts ??
        payload?.timestamp ??
        payload?.at ??
        payload?.time ??
        payload?.created_at ??
        payload?.updated_at ??
        Date.now()
    );
  }

  function processPayload(payload) {
    const type = getEventType(payload);
    const taskId = getTaskId(payload);
    const eventTs = getEventTs(payload);

    if (!taskId) {
      render();
      return;
    }

    if (RUNNING_EVENT_TYPES.has(type)) {
      if (!taskStartTimes.has(taskId)) {
        taskStartTimes.set(taskId, eventTs);
      }
    }

    if (TERMINAL_EVENT_TYPES.has(type)) {
      const dedupeKey = `${taskId}|${type}|${eventTs}`;

      if (!seenTerminalEvents.has(dedupeKey)) {
        seenTerminalEvents.add(dedupeKey);

        const startTs = taskStartTimes.get(taskId);
        if (Number.isFinite(startTs)) {
          const duration = Math.max(0, eventTs - startTs);
          recentDurationsMs.push(duration);
          if (recentDurationsMs.length > maxSamples) {
            recentDurationsMs.splice(0, recentDurationsMs.length - maxSamples);
          }
        }
      }

      taskStartTimes.delete(taskId);
    }

    render();
  }

  function attach(source) {
    if (!source || source.__phase65cLatencyBound) return;

    source.__phase65cLatencyBound = true;

    source.addEventListener("message", (e) => {
      try {
        const parsed = JSON.parse(e.data);
        if (Array.isArray(parsed)) {
          parsed.forEach(processPayload);
        } else {
          processPayload(parsed);
        }
      } catch {
        console.warn("latency_metric parse error");
      }
    });
  }

  function patchEventSource() {
    if (window.__phase65cLatencyPatched) return;

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
    window.__phase65cLatencyPatched = true;
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
