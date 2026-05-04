(() => {
  "use strict";

  // Phase16 SSE ownership guard (prevents duplicate stream consumption)
  if (typeof window !== "undefined" && window.__PHASE16_SSE_OWNER_STARTED) {
    return;
  }

  const URL = "/events/artifacts";

  let es = null;

  function connect() {
    try {
      es = new EventSource(URL);
    } catch (e) {
      console.warn("[project-visual-output] SSE init failed:", e);
      return;
    }

    es.onopen = () => {
      console.log("[project-visual-output] SSE connected");
    };

    es.onerror = () => {
      console.warn("[project-visual-output] SSE error");
      try { es.close(); } catch {}
    };

    es.onmessage = (evt) => {
      try {
        const data = JSON.parse(evt.data || "{}");
        window.dispatchEvent(
          new CustomEvent("mb:artifacts:update", { detail: data })
        );
      } catch (e) {
        console.warn("[project-visual-output] parse error:", e);
      }
    };
  }

  connect();
})();
