// public/js/ops-status-widget.js
// Phase 11: minimal pill ID normalizer; all state comes from ops-pill-state.js
(function () {
  if (typeof document === "undefined") return;

  var existing = document.getElementById("ops-status-pill");
  if (existing) return;

  var pill = document.querySelector("[data-ops-pill]");
  if (!pill) return;

  pill.id = "ops-status-pill";
})();
