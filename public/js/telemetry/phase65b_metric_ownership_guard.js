/*
PHASE 65B.1 — METRIC OWNERSHIP GUARD

Purpose:
Ensure metric-tasks is owned only by telemetry reducer.

Rules:
NO layout edits
NO protected file edits
NO SSE changes
Only prevent duplicate writers
*/

(function () {
  function guardMetric() {
    const node = document.getElementById("metric-tasks");
    if (!node) return;
    if (node.__phase65bOwned) return;

    const original = Object.getOwnPropertyDescriptor(
      Object.getPrototypeOf(node),
      "textContent"
    );

    if (!original || typeof original.set !== "function" || typeof original.get !== "function") {
      return;
    }

    Object.defineProperty(node, "textContent", {
      configurable: true,
      enumerable: original.enumerable,
      get() {
        return original.get.call(node);
      },
      set(value) {
        if (node.__phase65bTelemetryWrite) {
          original.set.call(node, value);
          return;
        }
        return;
      },
    });

    node.__phase65bOwned = true;
  }

  function allowTelemetryWrite(fn) {
    const node = document.getElementById("metric-tasks");
    if (!node) return fn();

    node.__phase65bTelemetryWrite = true;
    try {
      return fn();
    } finally {
      node.__phase65bTelemetryWrite = false;
    }
  }

  window.__phase65bMetricWrite = allowTelemetryWrite;

  function bootstrap() {
    guardMetric();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", bootstrap);
  } else {
    bootstrap();
  }
})();
