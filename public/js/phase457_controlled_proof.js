(() => {
  "use strict";

  // PHASE 464.11 — BOUNDED HOTFIX
  // Remove phase457 proof as a second operator-guidance writer.
  // Guidance panel ownership remains with public/js/operatorGuidance.sse.js only.

  if (window.__PHASE457_PROOF_EXECUTED__) return;
  window.__PHASE457_PROOF_EXECUTED__ = true;

  function byId(id) {
    return document.getElementById(id);
  }

  function hasOperatorGuidanceSurface() {
    return !!byId("operator-guidance-response") && !!byId("operator-guidance-meta");
  }

  function boot() {
    // Do not write to the operator guidance panel.
    // This file is intentionally neutralized to avoid duplicate guidance producers.
    if (hasOperatorGuidanceSurface()) {
      window.__PHASE457_PROOF_NEUTRALIZED__ = true;
      return;
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
