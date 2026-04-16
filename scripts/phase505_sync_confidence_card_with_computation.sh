#!/usr/bin/env bash
set -euo pipefail

TARGET="public/dashboard.html"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="/tmp/dashboard_pre_phase505_${STAMP}.bak"

cp "${TARGET}" "${BACKUP}"

cat >> "${TARGET}" << 'SCRIPT'

<script>
// PHASE 505 — SAFE CARD SYNC (STRICT GUARDRAILS)

document.addEventListener("DOMContentLoaded", function () {

  function syncConfidenceCard() {

    const meta = document.getElementById("operator-guidance-meta");
    if (!meta) return;

    const result = window.__PHASE501_CONFIDENCE__;

    // HARD GUARD — fallback if trace missing or invalid
    if (!result || !result.trace || !result.trace.inputs) {
      meta.innerHTML = `
        Confidence: limited<br>
        Sources: diagnostics/system-health
      `;
      return;
    }

    const { confidence, trace } = result;

    // HARD GUARD — require ALL signals to be non-null and non-unknown
    const requiredSignals = [
      "guidance_availability",
      "evidence_presence",
      "governance_resolution",
      "execution_readiness",
      "explanation_integrity"
    ];

    for (const key of requiredSignals) {
      if (
        !trace.inputs[key] ||
        trace.inputs[key] === "unknown"
      ) {
        meta.innerHTML = `
          Confidence: limited<br>
          Sources: diagnostics/system-health
        `;
        return;
      }
    }

    // HARD GUARD — explanation must be complete
    if (trace.inputs.explanation_integrity !== "complete") {
      meta.innerHTML = `
        Confidence: limited<br>
        Sources: diagnostics/system-health
      `;
      return;
    }

    // SAFE: reflect computed confidence
    meta.innerHTML = `
      Confidence: ${confidence}<br>
      Sources: diagnostics/system-health
    `;
  }

  // Initial sync
  syncConfidenceCard();

  // Re-sync after signals settle
  setTimeout(syncConfidenceCard, 500);
});
</script>

SCRIPT

echo "Phase 505 confidence card sync applied to ${TARGET}"
