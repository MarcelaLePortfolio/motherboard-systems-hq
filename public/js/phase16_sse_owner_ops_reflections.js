(() => {
  if (window.__PHASE16_SSE_OWNER_STARTED) return;
  window.__PHASE16_SSE_OWNER_STARTED = true;

  function safeJson(s) { try { return JSON.parse(s); } catch { return null; } }

  function emit(domType, mbKey, rawEventName, rawData) {
    const parsed = safeJson(rawData);
    // 1) DOM events that the UI listens to (e.g. window.addEventListener("ops.state", ...))
    try {
      window.dispatchEvent(new CustomEvent(domType, { detail: parsed ?? rawData }));
    } catch {}

    // 2) unified debug/bridge event (your proof listener)
    try {
      window.dispatchEvent(new CustomEvent(`mb:${mbKey}:update`, {
        detail: { event: rawEventName, state: parsed ?? rawData, raw: parsed }
      }));
    } catch {}
  }

  // OPS
  window.__opsES = new EventSource("/events/ops");

  window.__opsES.addEventListener("hello", (e) => {
    emit("ops.hello", "ops", "hello", e.data);
  });

  window.__opsES.addEventListener("ops.state", (e) => {
    emit("ops.state", "ops", "ops.state", e.data);
  });

  // If heartbeats ever exist, harmless to listen
  window.__opsES.addEventListener("ops.heartbeat", (e) => {
    emit("ops.heartbeat", "ops", "ops.heartbeat", e.data);
  });

  // Reflections
  window.__refES = new EventSource("/events/reflections");

  window.__refES.addEventListener("hello", (e) => {
    emit("reflections.hello", "reflections", "hello", e.data);
  });

  window.__refES.addEventListener("reflections.state", (e) => {
    emit("reflections.state", "reflections", "reflections.state", e.data);
  });
})();