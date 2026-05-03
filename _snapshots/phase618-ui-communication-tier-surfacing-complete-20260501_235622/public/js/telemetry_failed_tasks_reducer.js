/*
PHASE 66D — FAILED TASKS REDUCER
Deterministic telemetry reducer
NO UI mutations allowed
*/

(function () {
  let failedTaskCount = 0;
  const seenFailureEvents = new Set();

  function getEventKey(evt) {
    if (!evt || !evt.task_id || !evt.state) {
      return null;
    }

    return [
      evt.task_id,
      evt.run_id || "",
      evt.state,
      evt.ts || "",
    ].join("::");
  }

  function processEvent(evt) {
    if (!evt || evt.state !== "task.failed" || !evt.task_id) {
      return;
    }

    const eventKey = getEventKey(evt);
    if (!eventKey || seenFailureEvents.has(eventKey)) {
      return;
    }

    seenFailureEvents.add(eventKey);
    failedTaskCount += 1;
  }

  function getFailedTaskCount() {
    return failedTaskCount;
  }

  function reset() {
    failedTaskCount = 0;
    seenFailureEvents.clear();
  }

  if (window.telemetryBus && window.telemetryBus.subscribe) {
    window.telemetryBus.subscribe("task-events", processEvent);
  }

  window.failedTasksTelemetry = {
    getFailedTaskCount,
    reset,
  };
})();
