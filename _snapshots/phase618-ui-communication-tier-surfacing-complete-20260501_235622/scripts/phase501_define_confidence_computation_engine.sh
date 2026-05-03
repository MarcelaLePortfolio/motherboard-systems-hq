#!/usr/bin/env bash
set -euo pipefail

TARGET="public/dashboard.html"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="/tmp/dashboard_pre_phase501_${STAMP}.bak"

cp "${TARGET}" "${BACKUP}"

cat >> "${TARGET}" << 'SCRIPT'

<script>
// PHASE 501 — CONFIDENCE COMPUTATION ENGINE (NO UI MUTATION)

// PURE FUNCTION — uses ONLY exposed signals
function phase501_compute_confidence(signals) {

  const trace = {
    inputs: { ...signals },
    rules_applied: [],
    result: "limited"
  };

  // HARD GUARD — missing signals = limited
  for (const key of [
    "guidance_availability",
    "evidence_presence",
    "governance_resolution",
    "execution_readiness",
    "explanation_integrity"
  ]) {
    if (!signals[key] || signals[key] === "unknown") {
      trace.rules_applied.push(`missing_or_unknown_${key}`);
      return { confidence: "limited", trace };
    }
  }

  // EXPLANATION INTEGRITY GUARD
  if (signals.explanation_integrity !== "complete") {
    trace.rules_applied.push("explanation_incomplete");
    return { confidence: "limited", trace };
  }

  // LIMITED → MODERATE THRESHOLD (ALL REQUIRED CONDITIONS)
  if (
    signals.guidance_availability === "present" &&
    signals.evidence_presence === "present" &&
    signals.governance_resolution === "resolved" &&
    (signals.execution_readiness === "ready" || signals.execution_readiness === "present")
  ) {
    trace.rules_applied.push("moderate_threshold_met");
    trace.result = "moderate";
    return { confidence: "moderate", trace };
  }

  // HIGH THRESHOLD (STRICTER — future-ready)
  if (
    signals.guidance_availability === "present" &&
    signals.evidence_presence === "present" &&
    signals.governance_resolution === "resolved" &&
    signals.execution_readiness === "ready" &&
    signals.explanation_integrity === "complete"
  ) {
    trace.rules_applied.push("high_threshold_met");
    trace.result = "high";
    return { confidence: "high", trace };
  }

  // DEFAULT: LIMITED (explicit)
  trace.rules_applied.push("default_limited");
  return { confidence: "limited", trace };
}

// STORE RESULT WITHOUT TOUCHING UI
document.addEventListener("DOMContentLoaded", function () {
  if (!window.__PHASE494_SIGNALS__) return;

  const result = phase501_compute_confidence(window.__PHASE494_SIGNALS__);

  window.__PHASE501_CONFIDENCE__ = result;

  // OPTIONAL: expose for debugging (no UI binding)
  console.log("PHASE501_CONFIDENCE_TRACE", result);
});
</script>

SCRIPT

echo "Phase 501 confidence computation engine defined (no UI mutation)"
