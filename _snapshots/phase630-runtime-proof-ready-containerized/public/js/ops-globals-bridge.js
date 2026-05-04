// Lightweight OPS SSE → global state bridge for Phase 11
(() => {
  // Phase16: bail if SSE owner already started
  if (typeof window !== "undefined" && window.__PHASE16_SSE_OWNER_STARTED) return;

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
  
  // Phase16: emit a unified CustomEvent for OPS pill + listeners
  try {
    window.dispatchEvent(new CustomEvent("mb:ops:update", {
      detail: { event: "message", state: window.lastOpsStatusSnapshot }
    }));
  } catch {}
};

  try {
    const es = (window.__PHASE16_SSE_OWNER_STARTED ? null : new EventSource(opsUrl));

    // Default unnamed "message" events (if any in future)
    // Phase16: guard null EventSource before handlers

    if (!es) return null;

    es.onmessage = handleEvent;

    // Named "hello" events from OPS SSE
    es.addEventListener("hello", handleEvent);

    // Phase16: guard null EventSource before handlers (onerror)

    if (!es) return;

    es.onerror = (err) => {
      console.warn("[ops-globals-bridge] EventSource error:", err);
    };
  } catch (err) {
    console.warn("[ops-globals-bridge] Failed to init EventSource:", err);
  }
})();
