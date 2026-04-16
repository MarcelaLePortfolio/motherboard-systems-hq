#!/usr/bin/env bash
set -euo pipefail

TARGET="public/dashboard.html"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="/tmp/dashboard_pre_phase509_${STAMP}.bak"

cp "${TARGET}" "${BACKUP}"

cat >> "${TARGET}" << 'SCRIPT'

<script>
// PHASE 509 — WIRE guidance_availability FROM REAL ENDPOINT (NO FAKE SIGNALS)

document.addEventListener("DOMContentLoaded", async function () {
  try {
    const res = await fetch("/api/guidance");
    const data = await res.json();

    if (!window.__PHASE494_SIGNALS__) return;

    // DEFAULT: absent
    window.__PHASE494_SIGNALS__.guidance_availability = "absent";

    // ONLY elevate if endpoint explicitly says available
    if (data && data.guidance_available === true) {
      window.__PHASE494_SIGNALS__.guidance_availability = "present";
    }

  } catch (e) {
    if (window.__PHASE494_SIGNALS__) {
      window.__PHASE494_SIGNALS__.guidance_availability = "unknown";
    }
  }
});
</script>

SCRIPT

echo "Phase 509 guidance_availability now wired to /api/guidance endpoint"
