(() => {
  if (window.__PHASE16_SSE_OWNER_STARTED) return;
  window.__PHASE16_SSE_OWNER_STARTED = true;

  function safeParse(s) { try { return JSON.parse(s); } catch (_) { return null; } }

  function start(url, kind) {
    const es = new EventSource(url);

    es.addEventListener("hello", (e) => {
      console.log(`[SSE ${kind}] hello`, e.data);
    });

    es.addEventListener("ops.state", (e) => {
      const state = safeParse(e.data);
      if (state) window.dispatchEvent(new CustomEvent("ops.state", { detail: state }));
    });

    es.addEventListener("reflections.state", (e) => {
      const snap = safeParse(e.data);
      if (snap) window.dispatchEvent(new CustomEvent("reflections.state", { detail: snap }));
    });

    es.addEventListener("reflections.add", (e) => {
      const payload = safeParse(e.data);
      if (payload) window.dispatchEvent(new CustomEvent("reflections.add", { detail: payload }));
    });

    es.addEventListener("error", (e) => {
      console.log(`[SSE ${kind}] error`, e);
    });

    return es;
  }

  try { window.__opsES?.close?.(); } catch (_) {}
  try { window.__refES?.close?.(); } catch (_) {}

  window.__opsES = start("/events/ops", "ops");
  window.__refES = start("/events/reflections", "reflections");

  console.log("✅ Phase16 SSE owner active (ops + reflections)");
})();
