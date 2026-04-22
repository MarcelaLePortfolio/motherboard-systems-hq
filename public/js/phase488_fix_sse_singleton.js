(function () {
  if (window.__PHASE488_SSE_GUARD__) {
    console.log("[PHASE488_FIX] SSE already initialized, skipping duplicate init");
    return;
  }

  window.__PHASE488_SSE_GUARD__ = true;

  const streams = [
    "/events/ops",
    "/events/reflections",
    "/events/task-events"
  ];

  window.__MB_STREAMS = window.__MB_STREAMS || {};

  streams.forEach((url) => {
    try {
      if (window.__MB_STREAMS[url]) {
        console.log("[PHASE488_FIX] stream already exists:", url);
        return;
      }

      const es = // PHASE488_DISABLED new EventSource(url);
      window.__MB_STREAMS[url] = { es };

      es.onopen = () => console.log("[PHASE488_FIX] opened:", url);
      es.onerror = () => console.log("[PHASE488_FIX] error:", url);

    } catch (e) {
      console.error("[PHASE488_FIX] failed to init stream:", url, e);
    }
  });

  console.log("[PHASE488_FIX] SSE singleton guard active");
})();
