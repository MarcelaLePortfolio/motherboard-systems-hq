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
