(() => {
  if (window.__OPERATOR_GUIDANCE_STREAM_ACTIVE__) return;
  window.__OPERATOR_GUIDANCE_STREAM_ACTIVE__ = true;

  const RESPONSE_EL = document.getElementById("operator-guidance-response");
  const META_EL = document.getElementById("operator-guidance-meta");

  let eventSource = null;

  function closeStream() {
    if (eventSource) {
      eventSource.close();
      eventSource = null;
    }
  }

  function startStream() {
    if (eventSource) return;

    eventSource = new EventSource("/events/operator-guidance");

    eventSource.onmessage = (event) => {
      try {
        const data = JSON.parse(event.data);

        if (RESPONSE_EL) {
          RESPONSE_EL.textContent = String(data?.message ?? "").trim();
        }

        if (META_EL) {
          META_EL.textContent = String(data?.meta ?? "").trim();
        }
      } catch (_) {}
    };

    eventSource.onerror = () => {
      closeStream();
    };
  }

  startStream();

  document.addEventListener("visibilitychange", () => {
    if (document.visibilityState === "hidden") {
      closeStream();
    }
  });

  window.addEventListener("beforeunload", () => {
    closeStream();
  });
})();
