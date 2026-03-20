/*
PHASE 66B — QUEUE DEPTH REDUCER
Deterministic telemetry reducer
NO UI mutations allowed
*/

(function () {
  const queueSet = new Set();

  function isAddEvent(state) {
    return state === "task.created" || state === "task.queued";
  }

  function isRemoveEvent(state) {
    return (
      state === "task.started" ||
      state === "task.completed" ||
      state === "task.failed" ||
      state === "task.cancelled"
    );
  }

  function processEvent(evt) {
    if (!evt || !evt.task_id || !evt.state) {
      return;
    }

    const taskId = evt.task_id;
    const state = evt.state;

    if (isAddEvent(state)) {
      queueSet.add(taskId);
      return;
    }

    if (isRemoveEvent(state)) {
      if (queueSet.has(taskId)) {
        queueSet.delete(taskId);
      }
      return;
    }
  }

  function getQueueDepth() {
    return queueSet.size;
  }

  function reset() {
    queueSet.clear();
  }

  // Telemetry bus registration only
  if (window.telemetryBus && window.telemetryBus.subscribe) {
    window.telemetryBus.subscribe("task-events", processEvent);
  }

  // Read-only exposure for metrics layer
  window.queueDepthTelemetry = {
    getQueueDepth,
    reset,
  };
})();
