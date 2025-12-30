(() => {
  if (window.__PHASE16_SSE_OWNER_STARTED) return;
  window.__PHASE16_SSE_OWNER_STARTED = true;

  const safeJson = (s) => { try { return JSON.parse(s); } catch { return null; } };

  window.__opsES = new EventSource("/events/ops");
  window.__opsES.addEventListener("ops.state", (e) => {
    const data = safeJson(e.data);
    if (data) window.dispatchEvent(new CustomEvent("ops.state", { detail: data }));
  });

  window.__refES = new EventSource("/events/reflections");
  window.__refES.addEventListener("reflections.state", (e) => {
    const data = safeJson(e.data);
    if (data) window.dispatchEvent(new CustomEvent("reflections.state", { detail: data }));
  });
  window.__refES.addEventListener("reflections.add", (e) => {
    const data = safeJson(e.data);
    if (data) window.dispatchEvent(new CustomEvent("reflections.add", { detail: data }));
  });
})();
