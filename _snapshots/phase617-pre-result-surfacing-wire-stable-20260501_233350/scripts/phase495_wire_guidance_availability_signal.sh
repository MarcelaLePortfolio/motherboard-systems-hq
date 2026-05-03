#!/usr/bin/env bash
set -euo pipefail

TARGET="public/dashboard.html"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="/tmp/dashboard_pre_phase495_${STAMP}.bak"

cp "${TARGET}" "${BACKUP}"

cat >> "${TARGET}" << 'SCRIPT'

<script>
// PHASE 495 — WIRE guidance_availability (SAFE, NO COMPUTATION)

document.addEventListener("DOMContentLoaded", async function () {
  try {
    const res = await fetch("/diagnostics/system-health");
    const data = await res.json();

    // VERY LIGHT INTERPRETATION (allowed: presence only)
    if (data && typeof data === "object") {
      window.__PHASE494_SIGNALS__.guidance_availability = "absent";
      
      // If future signal appears, this can flip to "present"
      if (data.operatorGuidance || data.guidanceStream) {
        window.__PHASE494_SIGNALS__.guidance_availability = "present";
      }
    }
  } catch (e) {
    window.__PHASE494_SIGNALS__.guidance_availability = "unknown";
  }
});
</script>

SCRIPT

echo "Phase 495 guidance_availability signal wiring applied to ${TARGET}"
