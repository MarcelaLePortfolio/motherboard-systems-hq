// Lightweight OPS SSE → global state bridge for Phase 11
(() => {
if (typeof window === "undefined") return;

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

const opsUrl = ${window.location.protocol}//${window.location.hostname}:3201/events/ops;

try {
const es = new EventSource(opsUrl);

es.onmessage = (event) => {
  try {
    const data = JSON.parse(event.data);

    if (data && data.type === "heartbeat") {
      window.lastOpsHeartbeat =
        typeof data.timestamp === "number"
          ? data.timestamp
          : Math.floor(Date.now() / 1000);
    }

    if (
      data &&
      (data.type === "pm2-status" ||
        data.processes ||
        data.pm2 ||
        data.status === "pm2-status")
    ) {
      window.lastOpsStatusSnapshot = data;
    }
  } catch (err) {
    console.warn("[ops-globals-bridge] Failed to parse OPS event:", err);
  }
};

es.onerror = (err) => {
  console.warn("[ops-globals-bridge] EventSource error:", err);
};


} catch (err) {
console.warn("[ops-globals-bridge] Failed to init EventSource:", err);
}
})();
