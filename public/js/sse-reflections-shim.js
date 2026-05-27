// Phase 11 – SSE shim to disable Reflections EventSource until backend is ready

(function () {
  if (typeof window === "undefined") return;
  if (typeof window.EventSource === "undefined") return;

  const NativeEventSource = window.EventSource;

  function ReflectionsSafeEventSource(url, eventSourceInitDict) {
    if (typeof url === "string" && url.indexOf("events/reflections") !== -1) {
      console.warn(
        "[SSE SHIM] Reflections SSE disabled; backend not available. Returning dummy EventSource."
      );

      const dummy = {
        close() {},
        onmessage: null,
        onerror: null,
        addEventListener() {},
        removeEventListener() {},
        dispatchEvent() {
          return false;
        },
      };

      return dummy;
    }

    return new NativeEventSource(url, eventSourceInitDict);
  }

  ReflectionsSafeEventSource.prototype = NativeEventSource.prototype;
  window.EventSource = ReflectionsSafeEventSource;
})();
