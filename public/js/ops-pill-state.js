// public/js/ops-pill-state.js
// Phase 11: simplify OPS pill logic to avoid flip-flopping.
// The pill now has a single owner for label/classes and only shows:
// - "OPS: Unknown" when no heartbeat is known
// - "OPS: Online" once a heartbeat has been seen

(function () {
if (typeof window === "undefined" || typeof document === "undefined") return;

var POLL_INTERVAL_MS = 5000;

function applyState() {
var pill = document.getElementById("ops-status-pill");
if (!pill) return;

var hb = typeof window.lastOpsHeartbeat === "number" ? window.lastOpsHeartbeat : null;

var label = "OPS: Unknown";
var cls = "ops-pill-unknown";

if (hb) {
  label = "OPS: Online";
  cls = "ops-pill-online";
}

pill.classList.remove(
  "ops-pill-unknown",
  "ops-pill-online",
  "ops-pill-stale",
  "ops-pill-error"
);
pill.classList.add(cls);
pill.textContent = label;


}

// Initial run and periodic updates in case the heartbeat arrives later.
applyState();
setInterval(applyState, POLL_INTERVAL_MS);
})();
