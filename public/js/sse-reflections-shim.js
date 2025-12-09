// Phase 11 – SSE shim to disable Reflections EventSource until backend is ready

(function () {
if (typeof window === "undefined") return;
if (typeof window.EventSource === "undefined") return;

const NativeEventSource = window.EventSource;

function ReflectionsSafeEventSource(url, eventSourceInitDict) {
try {
if (typeof url === "string" && url.includes("events/reflections")) {
console.warn(
"[SSE SHIM] Reflections SSE disabled; backend not available. Returning dummy EventSource."
);

```
    const dummy = {
      close() {},
      onmessage: null,
      onerror: null,
      addEventListener() {},
      removeEventListener() {},
      dispatchEvent() { return false; }
    };

    return dummy;
  }

  return new NativeEventSource(url, eventSourceInitDict);
} catch (err) {
  console.error(
    "[SSE SHIM] Error constructing EventSource, falling back to native:",
    err
  );
  return new NativeEventSource(url, eventSourceInitDict);
}
```

}

ReflectionsSafeEventSource.prototype = NativeEventSource.prototype;
window.EventSource = ReflectionsSafeEventSource;
})();
