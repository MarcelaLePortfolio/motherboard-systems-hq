(() => {
  // HARD SINGLETON (per tab)
  if (window.__OPERATOR_GUIDANCE_STREAM_ACTIVE__) return;
  window.__OPERATOR_GUIDANCE_STREAM_ACTIVE__ = true;

  const RESPONSE_EL = document.getElementById("operator-guidance-response");
  const META_EL = document.getElementById("operator-guidance-meta");

  let eventSource = null;

  function closeStream() {
    if (eventSource) {
      eventSource.close();
      eventSource = null;
    }
  }

  function startStream() {
    // 🚫 NEVER restart if already created
    if (eventSource) return;

    eventSource = new EventSource("/api/operator-guidance");

    eventSource.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);

        // 🔒 CRITICAL FIX — HARD OVERWRITE (NO ACCUMULATION)
        if (RESPONSE_EL) {
          RESPONSE_EL.textContent = (data.message || "").trim();
        }

        if (META_EL) {
          META_EL.textContent = (data.meta || "").trim();
        }

      } catch (_) {}
    };

    eventSource.onerror = () => {
      // ❗ NEVER reconnect automatically
      closeStream();
    };
  }

  // 🚀 RUN ONCE ONLY
  startStream();

  // 🔒 NO RESTART ON VISIBILITY / FOCUS
  document.addEventListener("visibilitychange", () => {
    if (document.visibilityState === "hidden") {
      closeStream();
    }
  });

  window.addEventListener("beforeunload", () => {
    closeStream();
  });

})();
