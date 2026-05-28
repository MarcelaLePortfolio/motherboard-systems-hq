(() => {
  "use strict";

  if (window.__PHASE457_NEUTRALIZER_ACTIVE__) return;
  window.__PHASE457_NEUTRALIZER_ACTIVE__ = true;

  // 🔒 PHASE 457 HOTFIX:
  // Disable operator guidance normalization ONLY
  // Preserve all other panel behavior

  function byId(id) {
    return document.getElementById(id);
  }

  function isProbeLike(raw) {
    const text = String(raw || "");
    const lower = text.toLowerCase();

    return (
      !text.trim() ||
      /probe:/.test(lower) ||
      /loading/.test(lower) ||
      /updated_at/.test(lower) ||
      /run_view/.test(lower) ||
      /does not exist/.test(lower)
    );
  }

  function setIfProbeLike(node, fallbackText) {
    if (!node) return;
    if (!isProbeLike(node.textContent || "")) return;
    node.textContent = fallbackText;
  }

  function normalizeLegacyStatusPanels() {
    setIfProbeLike(byId("tasks-widget"), "No recent tasks yet.");
    setIfProbeLike(byId("recentLogs"), "No task history yet.");
  }

  function boot() {
    normalizeLegacyStatusPanels();

    // 🚫 CRITICAL: DO NOT TOUCH OPERATOR GUIDANCE
    // Previously caused infinite render loop via MutationObserver
    // Guidance is now controlled ONLY by Phase 456 baseline emitter
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
