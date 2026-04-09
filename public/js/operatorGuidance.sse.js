(() => {
  "use strict";

  if (window.__PHASE456_MINIMAL_GUIDANCE_EMITTER__) return;
  window.__PHASE456_MINIMAL_GUIDANCE_EMITTER__ = true;

  function byId(id) {
    return document.getElementById(id);
  }

  function renderBaseline() {
    const response = byId("operator-guidance-response");
    const meta = byId("operator-guidance-meta");

    if (!response || !meta) return;

    response.textContent =
      "SYSTEM_HEALTH • INFO • HIGH\n" +
      "System operational. No active tasks. Awaiting operator input.";

    meta.textContent =
      "Source: deterministic-baseline • Confidence: high • Mode: stable";
  }

  function boot() {
    renderBaseline();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
