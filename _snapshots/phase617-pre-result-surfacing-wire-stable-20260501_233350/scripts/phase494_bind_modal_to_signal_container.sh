#!/usr/bin/env bash
set -euo pipefail

TARGET="public/dashboard.html"

STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="/tmp/dashboard_pre_phase494_${STAMP}.bak"

cp "${TARGET}" "${BACKUP}"

# Inject signal container + dynamic rendering script
cat >> "${TARGET}" << 'SCRIPT'

<script>
// PHASE 494 — SIGNAL CONTAINER (SAFE, FRONTEND ONLY)
window.__PHASE494_SIGNALS__ = {
  guidance_availability: null,
  evidence_presence: null,
  governance_resolution: null,
  execution_readiness: null,
  explanation_integrity: null
};

// PHASE 494 — DYNAMIC MODAL RENDER (NO LOGIC CHANGE)
document.addEventListener("DOMContentLoaded", function () {
  const modalContent = document.querySelector("#phase493-reasoning-modal div div:nth-child(2)");

  if (!modalContent) return;

  const s = window.__PHASE494_SIGNALS__;

  function val(x) {
    return x === null ? "unknown" : x;
  }

  modalContent.innerHTML = `
    <strong>Signal state:</strong><br>
    • guidance_availability: ${val(s.guidance_availability)}<br>
    • evidence_presence: ${val(s.evidence_presence)}<br>
    • governance_resolution: ${val(s.governance_resolution)}<br>
    • execution_readiness: ${val(s.execution_readiness)}<br>
    • explanation_integrity: ${val(s.explanation_integrity)}<br><br>

    <strong>Interpretation:</strong><br>
    Confidence remains limited due to missing or incomplete signals.
  `;
});
</script>

SCRIPT

echo "Phase 494 signal binding scaffold applied to ${TARGET}"
