(function () {
  if (window.__PHASE488_SSE_SINGLETON__) {
    console.log("[PHASE488_FIX] SSE already initialized, skipping");
    return;
  }

  window.__PHASE488_SSE_SINGLETON__ = true;

  const STREAMS = [
    "/events/ops",
    "/events/reflections",
    "/events/task-events"
  ];

  window.__MB_STREAMS = window.__MB_STREAMS || {};

  STREAMS.forEach((url) => {
    if (window.__MB_STREAMS[url]) {
      console.log("[PHASE488_FIX] already exists:", url);
      return;
    }

    try {
      const es = new EventSource(url);
      window.__MB_STREAMS[url] = es;

      es.onopen = () => console.log("[PHASE488_FIX] open:", url);
      es.onerror = () => console.log("[PHASE488_FIX] error:", url);
    } catch (e) {
      console.error("[PHASE488_FIX] failed:", url, e);
    }
  });

  console.log("[PHASE488_FIX] SSE singleton active");
})();
