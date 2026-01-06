(() => {
const OPS_SSE_URL =
(typeof window !== "undefined" && window.OPS_SSE_URL) ||
"/events/ops";

// Close any existing OPS EventSource to avoid duplicates on hot reloads
if (typeof window !== "undefined" && window.esOps) {
try {
window.esOps.close();
} catch (e) {
console.warn("[OPS SSE] Error closing previous EventSource:", e);
}
}

if (typeof EventSource === "undefined") {
console.error("[OPS SSE] EventSource is not supported in this browser.");
return;
}

  probeSSE(OPS_SSE_URL).then((ok) => {
    if (!ok) {
      console.warn("[OPS SSE] Endpoint not available (skipping):", OPS_SSE_URL);
      return;
    }

    const es = (window.__PHASE16_SSE_OWNER_STARTED ? null : new EventSource(OPS_SSE_URL));
      if (!es) return;

    if (typeof window !== "undefined") {
      window.esOps = es;
    }

if (typeof window !== "undefined") {
if (typeof window.lastOpsHeartbeat === "undefined") {
window.lastOpsHeartbeat = null;
}
if (typeof window.lastOpsStatusSnapshot === "undefined") {
window.lastOpsStatusSnapshot = null;
}
}

es.addEventListener("open", () => {
console.log("[OPS SSE] Connection opened to", OPS_SSE_URL);
});

es.addEventListener("hello", (event) => {
console.log("[OPS hello]", event.data);
});

es.addEventListener("heartbeat", () => {
if (typeof window !== "undefined") {
window.lastOpsHeartbeat = Date.now();
}
});

es.addEventListener("pm2-status", (event) => {
try {
const data = JSON.parse(event.data);
if (typeof window !== "undefined") {
window.lastOpsStatusSnapshot = data;
}
console.log("[OPS pm2-status]", data);
} catch (err) {
console.error("[OPS pm2-status] Failed to parse payload:", err, event.data);
}
});

es.addEventListener("ops-error", (event) => {
console.error("[OPS ops-error]", event.data);
});

es.onerror = (err) => {
console.error("[OPS SSE] Error:", err);
};
})();
