(function () {
  const OPS_SSE_URL = "http://localhost:3201/events/ops";

  function startOpsSse() {
    // Clean up any prior listener to avoid duplicates on hot reloads
    if (window.esOps) {
      try {
        window.esOps.close();
      } catch (err) {
        console.warn("OPS SSE: error closing previous EventSource", err);
      }
    }

    console.log("OPS SSE: connecting to", OPS_SSE_URL);
    const es = new EventSource(OPS_SSE_URL);
    window.esOps = es;

    es.onmessage = (e) => {
      console.log("[OPS SSE]", e.data);
      try {
        const payload = JSON.parse(e.data);
        // Expose latest payload for future UI wiring
        window.lastOpsHeartbeat = payload;
      } catch (err) {
        console.warn("OPS SSE: non-JSON payload", e.data);
      }
    };

    es.onerror = (err) => {
      console.warn("OPS SSE: error, will retry in 5s", err);
      try {
        es.close();
      } catch (_) {}
      setTimeout(startOpsSse, 5000);
    };
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", startOpsSse);
  } else {
    startOpsSse();
  }
})();
