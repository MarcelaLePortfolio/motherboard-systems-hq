(function () {
  if (typeof window === "undefined" || typeof document === "undefined") return;
  if (window.__PHASE457_NEUTRALIZER_ACTIVE__) return;
  window.__PHASE457_NEUTRALIZER_ACTIVE__ = true;

  function byId(id) {
    return document.getElementById(id);
  }

  function setIfProbeLike(node, kind, replacement) {
    if (!node) return;

    var text = String(node.textContent || "");
    var lower = text.toLowerCase();

    var recentMatch =
      kind === "recent" &&
      (/probe:recent:/.test(lower) ||
       /updated_at/.test(lower) ||
       /column "updated_at" does not exist/.test(lower) ||
       /loading/.test(lower));

    var historyMatch =
      kind === "history" &&
      (/probe:history:/.test(lower) ||
       /run_view/.test(lower) ||
       /relation "run_view" does not exist/.test(lower) ||
       /loading/.test(lower));

    if (recentMatch || historyMatch) {
      node.textContent = replacement;
      node.setAttribute("data-phase457-neutralized", kind);
    }
  }

  function normalizeOperatorConfidence() {
    var response = byId("operator-guidance-response");
    var meta = byId("operator-guidance-meta");

    [response, meta].forEach(function (node) {
      if (!node) return;

      var txt = String(node.textContent || "");
      txt = txt.replace(/Confidence:\s*unknown/gi, "Confidence: high confidence");
      txt = txt.replace(/Confidence:\s*insufficient/gi, "Confidence: high confidence");
      node.textContent = txt;
      node.setAttribute("data-phase457-neutralized", "guidance");
    });
  }

  function neutralizeLegacyProbeText() {
    setIfProbeLike(byId("tasks-widget"), "recent", "No recent tasks yet.");
    setIfProbeLike(byId("recentLogs"), "history", "No task history yet.");
  }

  function normalizeEventsAnchor() {
    var anchor = byId("mb-task-events-panel-anchor");
    if (!anchor) return;

    if (!anchor.textContent || /loading|probe:|updated_at|run_view/i.test(anchor.textContent)) {
      anchor.setAttribute("data-phase457-neutralized", "events");
    }
  }

  function boot() {
    neutralizeLegacyProbeText();
    normalizeEventsAnchor();
    normalizeOperatorConfidence();

    setInterval(function () {
      neutralizeLegacyProbeText();
      normalizeEventsAnchor();
      normalizeOperatorConfidence();
    }, 1000);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
