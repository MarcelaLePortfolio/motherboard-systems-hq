// Lightweight OPS SSE → global state bridge for Phase 11
(() => {
  if (typeof window === "undefined" || typeof EventSource === "undefined") return;

  // Avoid multiple initializations if bundle is loaded twice
  if (window.__opsGlobalsBridgeInitialized) return;
  window.__opsGlobalsBridgeInitialized = true;

  // Initialize globals if they don't exist
  if (typeof window.lastOpsHeartbeat === "undefined") {
    window.lastOpsHeartbeat = null;
  }
  if (typeof window.lastOpsStatusSnapshot === "undefined") {
    window.lastOpsStatusSnapshot = null;
  }

  const opsUrl = `/events/ops`;

  

  const __DISABLE_OPTIONAL_SSE = (typeof window !== "undefined" && window.__DISABLE_OPTIONAL_SSE) === true;
  if (__DISABLE_OPTIONAL_SSE) {
    console.warn("[ops-globals-bridge] Optional SSE disabled (Phase 16 pending):", opsUrl);
    return;
  }
const handleEvent = (event) => {
    try {
      const data = JSON.parse(event.data || "null");
      if (!data) return;

      window.lastOpsHeartbeat = Math.floor(Date.now() / 1000);
      window.lastOpsStatusSnapshot = data;
    } catch (err) {
      console.warn("[ops-globals-bridge] Failed to parse OPS event:", err);
    }
  };

  try {
    const es = new EventSource(opsUrl);

    // Default unnamed "message" events (if any in future)
    es.onmessage = handleEvent;

    // Named "hello" events from OPS SSE
    es.addEventListener("hello", handleEvent);

    es.onerror = (err) => {
      console.warn("[ops-globals-bridge] EventSource error:", err);
    };
  } catch (err) {
    console.warn("[ops-globals-bridge] Failed to init EventSource:", err);
  }
})();
