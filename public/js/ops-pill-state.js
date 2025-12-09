// public/js/ops-pill-state.js
// Phase 11: simple OPS pill state based only on lastOpsHeartbeat.
(function () {
  if (typeof window === "undefined" || typeof document === "undefined") return;

  var POLL_INTERVAL_MS = 5000;

  function applyState() {
    var pill = document.getElementById("ops-status-pill");
    if (!pill) return;

    var hasHeartbeat = (typeof window.lastOpsHeartbeat === "number");

    var label = hasHeartbeat ? "OPS: Online" : "OPS: Unknown";
    var cls   = hasHeartbeat ? "ops-pill-online" : "ops-pill-unknown";

    pill.classList.remove(
      "ops-pill-unknown",
      "ops-pill-online",
      "ops-pill-stale",
      "ops-pill-error"
    );
    pill.classList.add(cls);
    pill.textContent = label;
  }

  applyState();
  setInterval(applyState, POLL_INTERVAL_MS);
})();
