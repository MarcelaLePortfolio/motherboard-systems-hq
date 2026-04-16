#!/usr/bin/env bash
set -euo pipefail

TARGET="public/dashboard.html"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="/tmp/dashboard_pre_phase496_${STAMP}.bak"

cp "${TARGET}" "${BACKUP}"

cat >> "${TARGET}" << 'SCRIPT'

<script>
// PHASE 496 — WIRE explanation_integrity (SAFE, UI-LOCAL, NO BACKEND)

document.addEventListener("DOMContentLoaded", function () {
  try {
    const modal = document.getElementById("phase493-reasoning-modal");

    if (!modal) {
      window.__PHASE494_SIGNALS__.explanation_integrity = "missing";
      return;
    }

    // Check if modal content exists and is non-empty
    const content = modal.querySelector("div div:nth-child(2)");

    if (!content || content.innerText.trim().length === 0) {
      window.__PHASE494_SIGNALS__.explanation_integrity = "partial";
      return;
    }

    // If content exists and is populated
    window.__PHASE494_SIGNALS__.explanation_integrity = "complete";

  } catch (e) {
    window.__PHASE494_SIGNALS__.explanation_integrity = "unknown";
  }
});
</script>

SCRIPT

echo "Phase 496 explanation_integrity signal wiring applied to ${TARGET}"
