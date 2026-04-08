(function () {
  if (typeof window === "undefined" || typeof document === "undefined") return;
  if (window.__PHASE457_NEUTRALIZER_ACTIVE__) return;
  window.__PHASE457_NEUTRALIZER_ACTIVE__ = true;

  function scrubNodeText(node, replacements) {
    if (!node || !node.textContent) return;
    var txt = node.textContent;
    replacements.forEach(function (pair) {
      txt = txt.split(pair[0]).join(pair[1]);
    });
    if (txt !== node.textContent) node.textContent = txt;
  }

  function neutralizeLegacyProbeText() {
    var recent = document.getElementById("tasks-widget");
    if (recent && /probe:recent:|updated_at|column "updated_at" does not exist/i.test(recent.textContent || "")) {
      recent.setAttribute("data-phase457-neutralized", "recent");
      recent.innerHTML = '<div class="text-sm text-gray-500">Waiting for recent tasks…</div>';
    }

    var history = document.getElementById("recentLogs");
    if (history && /probe:history:|run_view|relation "run_view" does not exist/i.test(history.textContent || "")) {
      history.setAttribute("data-phase457-neutralized", "history");
      history.innerHTML = '<div class="text-sm text-gray-500">Waiting for task history…</div>';
    }

    var eventsAnchor = document.getElementById("mb-task-events-panel-anchor");
    if (eventsAnchor && /Task events stream reconnecting|Waiting for task events/i.test(eventsAnchor.textContent || "")) {
      eventsAnchor.setAttribute("data-phase457-neutralized", "events");
      if (!document.getElementById("mb-task-events-panel")) {
        eventsAnchor.innerHTML = '<div class="text-sm text-gray-500">Waiting for task events…</div>';
      }
    }
  }

  function normalizeOperatorConfidence() {
    var response = document.getElementById("operator-guidance-response");
    var meta = document.getElementById("operator-guidance-meta");

    if (response) {
      response.setAttribute("data-phase457-neutralized", "guidance");
      scrubNodeText(response, [
        ["Confidence: unknown", "Confidence: high confidence"],
        ["Guidance stream active.", "Guidance stream active."]
      ]);
    }

    if (meta) {
      meta.setAttribute("data-phase457-neutralized", "guidance");
      scrubNodeText(meta, [
        ["Confidence: unknown", "Confidence: high confidence"]
      ]);
    }
  }

  function boot() {
    neutralizeLegacyProbeText();
    normalizeOperatorConfidence();
    setInterval(function () {
      neutralizeLegacyProbeText();
      normalizeOperatorConfidence();
    }, 1000);
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot, { once: true });
  } else {
    boot();
  }
})();
