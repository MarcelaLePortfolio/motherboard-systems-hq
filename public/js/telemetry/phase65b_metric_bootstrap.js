/*
Phase 65B / Phase 80.2 — Metric Bootstrap
Loads deterministic telemetry metric modules in a fixed order.
*/

(function () {
  function load(src) {
    try {
      var existing = document.querySelector('script[data-telemetry-src="' + src + '"]');
      if (existing) return;

      var script = document.createElement("script");
      script.src = src;
      script.async = false;
      script.defer = false;
      script.dataset.telemetrySrc = src;
      document.head.appendChild(script);
    } catch (err) {
      console.error("[telemetry-bootstrap] failed to load:", src, err);
    }
  }

  function start() {
    load("/js/telemetry/phase65b_metric_ownership_guard.js");
    load("/js/telemetry/running_tasks_metric.js");
    load("/js/telemetry/success_rate_metric.js");
    load("/js/telemetry/latency_metric.js");
    load("/js/telemetry/queue_latency_metric.js");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", start, { once: true });
  } else {
    start();
  }
})();
