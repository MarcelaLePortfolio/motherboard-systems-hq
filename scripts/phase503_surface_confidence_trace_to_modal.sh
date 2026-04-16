#!/usr/bin/env bash
set -euo pipefail

TARGET="public/dashboard.html"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="/tmp/dashboard_pre_phase503_${STAMP}.bak"

cp "${TARGET}" "${BACKUP}"

cat >> "${TARGET}" << 'SCRIPT'

<script>
// PHASE 503 — SAFE TRACE SURFACE (READ-ONLY, NO COMPUTATION MUTATION)

document.addEventListener("DOMContentLoaded", function () {

  const modalContent = document.querySelector("#phase493-reasoning-modal div div:nth-child(2)");
  if (!modalContent) return;

  function safeRender() {

    const result = window.__PHASE501_CONFIDENCE__;

    // HARD GUARD — fallback if trace missing
    if (!result || !result.trace) {
      modalContent.innerHTML = `
        <strong>Confidence:</strong> limited<br><br>
        <strong>Reason:</strong><br>
        Trace unavailable — system falling back to safe baseline.
      `;
      return;
    }

    const { confidence, trace } = result;

    const rules = (trace.rules_applied || []).map(r => `• ${r}`).join("<br>");

    const inputs = Object.entries(trace.inputs || {})
      .map(([k, v]) => `• ${k}: ${v}`)
      .join("<br>");

    modalContent.innerHTML = `
      <strong>Computed Confidence:</strong> ${confidence}<br><br>

      <strong>Signal Inputs:</strong><br>
      ${inputs}<br><br>

      <strong>Rules Applied:</strong><br>
      ${rules}
    `;
  }

  // Initial render
  safeRender();

  // Re-render if signals update later
  setTimeout(safeRender, 500);
});
</script>

SCRIPT

echo "Phase 503 trace surface applied to ${TARGET}"
