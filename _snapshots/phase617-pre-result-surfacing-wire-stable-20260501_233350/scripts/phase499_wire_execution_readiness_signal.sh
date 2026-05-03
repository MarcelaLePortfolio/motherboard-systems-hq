#!/usr/bin/env bash
set -euo pipefail

TARGET="public/dashboard.html"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="/tmp/dashboard_pre_phase499_${STAMP}.bak"

cp "${TARGET}" "${BACKUP}"

cat >> "${TARGET}" << 'SCRIPT'

<script>
// PHASE 499 — WIRE execution_readiness (SYSTEM-DERIVED, NO COMPUTATION)

document.addEventListener("DOMContentLoaded", async function () {
  try {
    const res = await fetch("/diagnostics/system-health");
    const data = await res.json();

    if (!window.__PHASE494_SIGNALS__) return;

    // Default state
    window.__PHASE494_SIGNALS__.execution_readiness = "unknown";

    if (data && typeof data === "object") {

      // Explicit readiness indicators (presence only)
      if (
        data.executionReady === true ||
        data.executionStatus === "ready"
      ) {
        window.__PHASE494_SIGNALS__.execution_readiness = "ready";
        return;
      }

      if (
        data.executionBlocked === true ||
        data.executionStatus === "blocked"
      ) {
        window.__PHASE494_SIGNALS__.execution_readiness = "blocked";
        return;
      }

      if (
        data.executionPending === true ||
        data.executionStatus === "pending"
      ) {
        window.__PHASE494_SIGNALS__.execution_readiness = "pending";
        return;
      }

      // Fallback presence detection
      if (data.execution || data.tasks || data.queue) {
        window.__PHASE494_SIGNALS__.execution_readiness = "present";
      } else {
        window.__PHASE494_SIGNALS__.execution_readiness = "absent";
      }
    }

  } catch (e) {
    if (window.__PHASE494_SIGNALS__) {
      window.__PHASE494_SIGNALS__.execution_readiness = "unknown";
    }
  }
});
</script>

SCRIPT

echo "Phase 499 execution_readiness signal wiring applied to ${TARGET}"
