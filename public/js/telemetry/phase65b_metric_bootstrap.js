/*
PHASE 65B SAFE TELEMETRY BOOTSTRAP

SAFE RULES:
NO SCRIPT ORDER CHANGE
NO BUNDLE MUTATION
ISOLATED LOADER ONLY
*/

(function () {
  const SCRIPT_ID = "phase65b-running-tasks-metric";

  function loadScript(src) {
    if (document.getElementById(SCRIPT_ID)) return;

    const s = document.createElement("script");
    s.id = SCRIPT_ID;
    s.src = src;
    s.defer = true;
    document.body.appendChild(s);
  }

  function init() {
    loadScript("/js/telemetry/running_tasks_metric.js");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
