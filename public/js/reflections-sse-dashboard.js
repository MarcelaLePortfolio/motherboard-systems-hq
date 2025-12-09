// Phase 11 – Reflections SSE wiring for dashboard bundle

(function () {
if (typeof window === "undefined") return;

if (typeof EventSource === "undefined") {
console.warn("[DASHBOARD REFLECTIONS] EventSource not supported in this environment.");
return;
}

try {
if (window.esRef && typeof window.esRef.close === "function") {
window.esRef.close();
}
} catch (err) {
console.warn("[DASHBOARD REFLECTIONS] Error closing existing esRef:", err);
}

const REFLECTIONS_SSE_URL = "[http://127.0.0.1:3200/events/reflections](http://127.0.0.1:3200/events/reflections)";

try {
const esRef = new EventSource(REFLECTIONS_SSE_URL);
window.esRef = esRef;

```
esRef.onmessage = (event) => {
  try {
    const data = JSON.parse(event.data);
    window.lastReflectionSnapshot = data;
    console.log("[DASHBOARD REFLECTIONS]", data);
  } catch (err) {
    console.error(
      "[DASHBOARD REFLECTIONS] Error parsing SSE payload:",
      err,
      event.data
    );
  }
};

esRef.onerror = (err) => {
  console.error("[DASHBOARD REFLECTIONS ERROR]", err);
};
```

} catch (err) {
console.error(
"[DASHBOARD REFLECTIONS] Failed to initialize EventSource:",
err
);
}
})();
