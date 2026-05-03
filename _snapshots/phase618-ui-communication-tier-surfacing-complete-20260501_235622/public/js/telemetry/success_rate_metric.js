/*
PHASE 65C TELEMETRY HYDRATION
Success Rate Metric
Telemetry now sole writer.
*/

(function () {
  const TERMINAL_SUCCESS_TYPES = new Set([
    "task.completed",
    "task.complete",
    "task.done",
    "task.success",
    "completed",
    "complete",
    "done",
    "success",
  ]);

  const TERMINAL_FAILURE_TYPES = new Set([
    "task.failed",
    "task.error",
    "task.cancelled",
    "task.canceled",
    "task.timed_out",
    "task.timeout",
    "failed",
    "error",
    "cancelled",
    "canceled",
    "timed_out",
    "timeout",
    "terminated",
    "aborted",
  ]);

  const seenTerminalEvents = new Set();
  let completedCount = 0;
  let failedCount = 0;

  function getMetricNode() {
    return document.getElementById("metric-success");
  }

  function render() {
    const node = getMetricNode();
    if (!node) return;

    const total = completedCount + failedCount;
    const value = total > 0 ? `${Math.round((completedCount / total) * 100)}%` : "—";

    if (window.__phase65bMetricWrite) {
      window.__phase65bMetricWrite(() => {
        node.textContent = value;
      });
    } else {
      node.textContent = value;
    }
  }

  function getEventType(payload, fallbackEventName) {
    return String(
      payload?.type ||
        payload?.event ||
        payload?.name ||
        payload?.kind ||
        payload?.status ||
        payload?.state ||
        fallbackEventName ||
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
        payload?.meta?.task_id ??
        payload?.meta?.taskId ??
        ""
    ).trim();
  }

  function getEventTs(payload) {
    const raw =
      payload?.ts ??
      payload?.timestamp ??
      payload?.at ??
      payload?.time ??
      payload?.created_at ??
      payload?.updated_at ??
      Date.now();

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

  function normalizePayload(payload, fallbackEventName) {
    const value = payload && typeof payload === "object" ? { ...payload } : {};
    const meta = value.meta && typeof value.meta === "object" ? value.meta : null;

    if (value.kind === "task.event" && value.type) {
      value.kind = value.type;
    }

    if (meta) {
      if (value.task_id == null && meta.task_id != null) value.task_id = meta.task_id;
      if (value.taskId == null && meta.taskId != null) value.taskId = meta.taskId;
      if (value.status == null && meta.status != null) value.status = meta.status;
      if (value.state == null && meta.state != null) value.state = meta.state;
      if (value.event == null && meta.event != null) value.event = meta.event;
      if (value.type == null && meta.type != null) value.type = meta.type;
    }

    value.__phase62bFallbackEventName = fallbackEventName || "";
    return value;
  }

  function processPayload(payload, fallbackEventName) {
    const normalized = normalizePayload(payload, fallbackEventName);
    const type = getEventType(normalized, fallbackEventName);
    const taskId = getTaskId(normalized);
    const ts = getEventTs(normalized);

    if (!type) {
      render();
      return;
    }

    const isSuccess = TERMINAL_SUCCESS_TYPES.has(type);
    const isFailure = TERMINAL_FAILURE_TYPES.has(type);

    if (!isSuccess && !isFailure) {
      render();
      return;
    }

    const dedupeKey = `${taskId || "no-task"}|${type}|${ts}`;
    if (seenTerminalEvents.has(dedupeKey)) {
      render();
      return;
    }

    seenTerminalEvents.add(dedupeKey);

    if (isSuccess) completedCount += 1;
    if (isFailure) failedCount += 1;

    render();
  }

  function attach(source) {
    if (!source || source.__phase65cSuccessBound) return;

    source.__phase65cSuccessBound = true;

    const handle = (fallbackEventName, e) => {
      try {
        const parsed = JSON.parse(e.data);
        if (Array.isArray(parsed)) {
          parsed.forEach((item) => processPayload(item, fallbackEventName));
        } else {
          processPayload(parsed, fallbackEventName);
        }
      } catch {
        console.warn("success_rate_metric parse error");
      }
    };

    const eventNames = [
      "message",
      "task.event",
      "task.completed",
      "task.failed",
      "task.updated",
      "task.status",
    ];

    eventNames.forEach((eventName) => {
      source.addEventListener(eventName, (e) => handle(eventName, e));
    });
  }

  function patchEventSource() {
    if (window.__phase65cSuccessPatched) return;

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
    window.__phase65cSuccessPatched = true;
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
