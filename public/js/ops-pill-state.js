// public/js/ops-pill-state.js
// Phase 11: simple dashboard OPS pill driven by lastOpsHeartbeat.
// - Creates #ops-dashboard-pill on /dashboard if missing.
// - Hides any external #ops-status-pill overlay.
// - Shows "OPS: Unknown" / "OPS: Online" based on heartbeat.

(function () {
  if (typeof window === "undefined" || typeof document === "undefined") return;
  if (window.location.pathname !== "/dashboard") return;

  var POLL_INTERVAL_MS = 5000;
  var PILL_ID = "ops-dashboard-pill";

  function ensurePill() {
    var pill = document.getElementById(PILL_ID);
    if (pill) return pill;

    // Create the dashboard pill near the top of the body
    pill = document.createElement("span");
    pill.id = PILL_ID;
    pill.className = "ops-pill ops-pill-unknown";
    pill.textContent = "OPS: Unknown";

    // Keep styling minimal; main styles come from CSS class
    pill.style.display = "inline-block";

    if (document.body.firstChild) {
      document.body.insertBefore(pill, document.body.firstChild);
    } else {
      document.body.appendChild(pill);
    }

    return pill;
  }

  function applyState() {
    // Always hide any external overlay pill if present
    var overlay = document.getElementById("ops-status-pill");
    if (overlay) {
      overlay.style.display = "none";
    }

    var pill = ensurePill();
    if (!pill) return;

    var hasHeartbeat = (typeof window.lastOpsHeartbeat === "number");

    var label = hasHeartbeat ? "OPS: Online"  : "OPS: Unknown";
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
