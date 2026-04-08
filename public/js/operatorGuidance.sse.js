(() => {
  "use strict";

  if (window.__OPERATOR_GUIDANCE_SSE_NEUTRALIZED__) return;
  window.__OPERATOR_GUIDANCE_SSE_NEUTRALIZED__ = true;

  function log() {
    try {
      console.log("[operatorGuidance.sse] DOM writer neutralized; phase457 renderer owns operator guidance");
    } catch {}
  }

  function boot() {
    log();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
