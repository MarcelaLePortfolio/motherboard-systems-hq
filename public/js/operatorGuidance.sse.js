(() => {
  "use strict";

  if (window.__PHASE456_OPERATOR_GUIDANCE_FIX__) return;
  window.__PHASE456_OPERATOR_GUIDANCE_FIX__ = true;

  const OPS_URL = "/events/ops";

  function byId(id) {
    return document.getElementById(id);
  }

  function safeParse(data) {
    try { return JSON.parse(data); } catch { return null; }
  }

  function normalizePayload(parsed) {
    if (!parsed || typeof parsed !== "object") return null;
    return parsed.payload || parsed.data || parsed;
  }

  function isValidGuidance(payload) {
    if (!payload || typeof payload !== "object") return false;

    const msg = String(payload.msg || payload.message || "").trim();

    // 🔒 HARD FILTER: kill heartbeats + empty + noise
    if (!msg) return false;
    if (payload.kind === "heartbeat") return false;
    if (/keepalive/i.test(msg)) return false;
    if (msg.length < 8) return false;

    return true;
  }

  function render(payload) {
    const response = byId("operator-guidance-response");
    const meta = byId("operator-guidance-meta");

    if (!response || !meta) return;

    const msg = String(payload.msg || payload.message || "System guidance available.");
    const ts = payload.ts || Date.now();

    response.textContent = msg;

    meta.textContent =
      "Source: ops-stream • " +
      "Confidence: high • " +
      "Updated: " + new Date(ts).toLocaleTimeString();
  }

  function connect() {
    let es;

    try {
      es = new EventSource(OPS_URL);
    } catch (err) {
      console.warn("[operatorGuidance] SSE failed to connect", err);
      return;
    }

    es.onopen = () => {
      console.log("[operatorGuidance] connected");
    };

    es.onerror = () => {
      console.warn("[operatorGuidance] error — reconnect handled by browser");
    };

    es.onmessage = (evt) => {
      const parsed = safeParse(evt.data);
      const payload = normalizePayload(parsed);

      if (!isValidGuidance(payload)) return;

      render(payload);
    };
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", connect);
  } else {
    connect();
  }
})();
