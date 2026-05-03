// Phase 11 – Reflections SSE wiring for dashboard bundle (temporarily disabled)

(function () {
if (typeof window === "undefined") return;

console.warn(
"[DASHBOARD REFLECTIONS] Reflections SSE backend endpoint not available; wiring is temporarily disabled. See PHASE11_REFLECTIONS_SSE_BACKEND_TODO.md for details."
);

// TODO: Re-enable EventSource wiring once a valid text/event-stream endpoint
// is running and reachable from the dashboard bundle.
})();
