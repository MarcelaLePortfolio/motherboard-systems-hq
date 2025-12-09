// public/js/ops-status-widget.js
// Phase 11: simplify OPS status widget so that ops-pill-state.js
// is the single owner of the OPS pill text and classes.
//
// This script now only normalizes the pill element ID.
// All label/visual state is driven by public/js/ops-pill-state.js.

(function () {
if (typeof document === "undefined") return;

// If the standardized pill already exists, do nothing.
var existing = document.getElementById("ops-status-pill");
if (existing) return;

// Backwards compatibility: if markup still uses data-ops-pill,
// normalize it to the canonical ID so ops-pill-state.js can find it.
var pill = document.querySelector("[data-ops-pill]");
if (!pill) return;

pill.id = "ops-status-pill";
})();
