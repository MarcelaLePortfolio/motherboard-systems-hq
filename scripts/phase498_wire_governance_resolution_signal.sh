#!/usr/bin/env bash
set -euo pipefail

TARGET="public/dashboard.html"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="/tmp/dashboard_pre_phase498_${STAMP}.bak"

cp "${TARGET}" "${BACKUP}"

cat >> "${TARGET}" << 'SCRIPT'

<script>
// PHASE 498 — WIRE governance_resolution (SYSTEM-DERIVED, NO COMPUTATION)

document.addEventListener("DOMContentLoaded", async function () {
  try {
    const res = await fetch("/diagnostics/system-health");
    const data = await res.json();

    if (!window.__PHASE494_SIGNALS__) return;

    // Default state
    window.__PHASE494_SIGNALS__.governance_resolution = "unresolved";

    if (data && typeof data === "object") {

      // Detect explicit governance outcomes (presence-only, no inference)
      if (
        data.governanceResolved === true ||
        data.governanceStatus === "resolved"
      ) {
        window.__PHASE494_SIGNALS__.governance_resolution = "resolved";
        return;
      }

      if (
        data.governanceBlocked === true ||
        data.governanceStatus === "blocked"
      ) {
        window.__PHASE494_SIGNALS__.governance_resolution = "blocked";
        return;
      }

      // Optional detection via decision containers
      if (data.governanceDecision || data.decision) {
        window.__PHASE494_SIGNALS__.governance_resolution = "resolved";
      }
    } else {
      window.__PHASE494_SIGNALS__.governance_resolution = "unknown";
    }

  } catch (e) {
    if (window.__PHASE494_SIGNALS__) {
      window.__PHASE494_SIGNALS__.governance_resolution = "unknown";
    }
  }
});
</script>

SCRIPT

echo "Phase 498 governance_resolution signal wiring applied to ${TARGET}"
