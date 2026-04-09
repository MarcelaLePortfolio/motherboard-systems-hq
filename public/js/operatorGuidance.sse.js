/**
 * PHASE 464.X — HARDENED SINGLE-SOURCE GUIDANCE STREAM
 *
 * Root cause (confirmed by behavior):
 * - Tab open / tab focus re-runs initialization
 * - Existing EventSource not cleaned or guarded
 * - Multiple streams stack → flood resumes
 *
 * Fix strategy (STRICTLY SINGLE FILE):
 * 1. Global singleton guard (prevents duplicate init)
 * 2. Active EventSource tracking
 * 3. Hard cleanup before re-init
 * 4. Visibility-safe (NO auto reconnect on focus)
 */

(function () {
  // 🔒 GLOBAL SINGLETON GUARD
  if (window.__OPERATOR_GUIDANCE_STREAM_ACTIVE__) {
    return;
  }
  window.__OPERATOR_GUIDANCE_STREAM_ACTIVE__ = true;

  let eventSource = null;

  const RESPONSE_EL = document.getElementById("operator-guidance-response");
  const META_EL = document.getElementById("operator-guidance-meta");

  function closeStream() {
    if (eventSource) {
      try {
        eventSource.close();
      } catch (_) {}
      eventSource = null;
    }
  }

  function startStream() {
    // 🧹 HARD RESET BEFORE START
    closeStream();

    // 🚫 DO NOT start if already active
    if (eventSource) return;

    eventSource = new EventSource("/api/operator-guidance");

    eventSource.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);

        // OVERWRITE ONLY (no append)
        if (RESPONSE_EL) {
          RESPONSE_EL.textContent = data.message || "";
        }

        if (META_EL) {
          META_EL.textContent = data.meta || "";
        }
      } catch (_) {}
    };

    eventSource.onerror = () => {
      // ❗ Do NOT auto-reconnect (prevents stacking)
      closeStream();
    };
  }

  // 🚀 INITIAL LOAD ONLY
  startStream();

  // 🧠 VISIBILITY HANDLING (NO RE-INIT)
  document.addEventListener("visibilitychange", () => {
    if (document.visibilityState === "hidden") {
      // Optional: close when hidden (safe)
      closeStream();
      window.__OPERATOR_GUIDANCE_STREAM_ACTIVE__ = false;
    }
  });

  // 🧹 HARD CLEANUP ON NAVIGATION
  window.addEventListener("beforeunload", () => {
    closeStream();
    window.__OPERATOR_GUIDANCE_STREAM_ACTIVE__ = false;
  });
})();
