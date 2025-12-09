// public/js/ops-pill-state.js
// Phase 11: harden OPS pill so it only shows:
// - "OPS: Unknown" when no heartbeat is known
// - "OPS: Online" once a heartbeat has been seen
// and ignores any external attempts to set "NO SIGNAL" or other labels.

(function () {
if (typeof window === "undefined" || typeof document === "undefined") return;

var POLL_INTERVAL_MS = 2000;

function computeState() {
var hb = typeof window.lastOpsHeartbeat === "number" ? window.lastOpsHeartbeat : null;

if (hb) {
  return {
    label: "OPS: Online",
    cls: "ops-pill-online"
  };
}

return {
  label: "OPS: Unknown",
  cls: "ops-pill-unknown"
};


}

function applyState() {
var pill = document.getElementById("ops-status-pill");
if (!pill) return;

var state = computeState();

pill.classList.remove(
  "ops-pill-unknown",
  "ops-pill-online",
  "ops-pill-stale",
  "ops-pill-error"
);
pill.classList.add(state.cls);
pill.textContent = state.label;

// Store expected label so the observer can correct external changes.
pill.dataset.opsPillExpectedLabel = state.label;


}

function attachObserver() {
var pill = document.getElementById("ops-status-pill");
if (!pill || pill.__opsPillObserverAttached) return;

pill.__opsPillObserverAttached = true;

var observer = new MutationObserver(function () {
  var pillEl = document.getElementById("ops-status-pill");
  if (!pillEl) return;
  var expected = pillEl.dataset.opsPillExpectedLabel;
  if (!expected) return;

  if (pillEl.textContent !== expected) {
    pillEl.textContent = expected;
  }
});

observer.observe(pill, {
  characterData: true,
  childList: true,
  subtree: true
});


}

// Initial run and periodic updates in case the heartbeat arrives later.
applyState();
attachObserver();

setInterval(function () {
applyState();
attachObserver();
}, POLL_INTERVAL_MS);
})();
