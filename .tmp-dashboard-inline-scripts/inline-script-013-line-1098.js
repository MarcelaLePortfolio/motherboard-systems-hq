// PHASE 497 — WIRE evidence_presence (SYSTEM-DERIVED, SAFE, NO COMPUTATION)

document.addEventListener("DOMContentLoaded", async function () {
  try {
    const res = await fetch("/diagnostics/system-health");
    const data = await res.json();

    if (!window.__PHASE494_SIGNALS__) return;

    // SYSTEM-LEVEL CHECK (no UI dependency)
    if (data && typeof data === "object") {
      // Default: no evidence
      window.__PHASE494_SIGNALS__.evidence_presence = "absent";

      // Detect possible evidence structures (non-opinionated, presence only)
      if (
        data.evidence ||
        data.evidenceLinks ||
        data.sources ||
        (Array.isArray(data.logs) && data.logs.length > 0) ||
        (Array.isArray(data.events) && data.events.length > 0)
      ) {
        window.__PHASE494_SIGNALS__.evidence_presence = "present";
      }
    } else {
      window.__PHASE494_SIGNALS__.evidence_presence = "unknown";
    }
  } catch (e) {
    if (window.__PHASE494_SIGNALS__) {
      window.__PHASE494_SIGNALS__.evidence_presence = "unknown";
    }
  }
});
