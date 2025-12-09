// Phase 11 – OPS pill state updater driven by OPS SSE globals
(() => {
if (typeof window === "undefined" || typeof document === "undefined") return;

const STALE_THRESHOLD_SECONDS = 30;
const POLL_INTERVAL_MS = 5000;

function computeState() {
const ts = window.lastOpsHeartbeat;

if (typeof ts !== "number") return "unknown";

const now = Math.floor(Date.now() / 1000);
const age = now - ts;

if (age < 0) return "unknown";
if (age <= STALE_THRESHOLD_SECONDS) return "online";
return "stale";


}

function applyState() {
const pill =
document.querySelector("[data-ops-pill]") ||
document.getElementById("ops-status-pill");

if (!pill) return;

const state = computeState();

pill.classList.remove(
  "ops-pill-online",
  "ops-pill-stale",
  "ops-pill-unknown"
);

let label = "OPS: Unknown";
let cls = "ops-pill-unknown";

if (state === "online") {
  label = "OPS: Online";
  cls = "ops-pill-online";
} else if (state === "stale") {
  label = "OPS: Stale";
  cls = "ops-pill-stale";
}

pill.classList.add(cls);

if (!pill.dataset || !pill.dataset.lockText) {
  pill.textContent = label;
}


}

applyState();
setInterval(applyState, POLL_INTERVAL_MS);
})();
