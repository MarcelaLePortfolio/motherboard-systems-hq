(function () {
  if (window.__PHASE573_EXECUTION_DEBUG__) return;
  window.__PHASE573_EXECUTION_DEBUG__ = true;

  function log(msg, data) {
    console.log("[execution-inspector-debug]", msg, data || "");
  }

  document.addEventListener("click", (e) => {
    const retry = e.target.closest('[data-action="retry"]');
    const requeue = e.target.closest('[data-action="requeue"]');

    if (retry) {
      log("RETRY CLICK DETECTED");
    }

    if (requeue) {
      log("REQUEUE CLICK DETECTED");
    }
  });

  window.addEventListener("mb.task.event", (e) => {
    log("TASK EVENT", e.detail);
  });

  log("Phase 573 debug active");
})();
