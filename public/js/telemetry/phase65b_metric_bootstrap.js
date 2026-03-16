(function () {
  function load(src) {
    if (document.querySelector(`script[src="${src}"]`)) return;

    const s = document.createElement("script");
    s.src = src;
    s.defer = true;
    document.body.appendChild(s);
  }

  function init() {
    load("/js/telemetry/phase65b_metric_ownership_guard.js");
    load("/js/telemetry/running_tasks_metric.js");
    load("/js/telemetry/success_rate_metric.js");
    load("/js/telemetry/latency_metric.js");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
