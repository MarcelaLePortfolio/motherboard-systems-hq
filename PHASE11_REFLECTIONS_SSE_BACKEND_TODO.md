Phase 11 – Reflections SSE Backend TODO (Post v11.8)

Tag v11.8-ops-pill-reflections-sse is in place. At this tag:

* OPS SSE is healthy on the dashboard.
* Reflections SSE frontend wiring was added and bundled.
* However, the backend endpoint does not provide a text/event-stream response.

The debug script scripts/debug/check_reflections_sse_endpoint.sh currently reports:

* [http://127.0.0.1:3101/events/reflections](http://127.0.0.1:3101/events/reflections)  -> curl failed
* [http://127.0.0.1:3200/events/reflections](http://127.0.0.1:3200/events/reflections)  -> curl failed
* [http://127.0.0.1:3201/events/reflections](http://127.0.0.1:3201/events/reflections)  -> HTTP 404, Content-Type: text/plain

No candidate endpoint returns Content-Type: text/event-stream, which is required for a valid SSE connection. As a result, the dashboard EventSource attempts were producing MIME-type errors in the browser.

To keep the v11.8 dashboard stable and clean while preserving future plans, the file public/js/reflections-sse-dashboard.js has been stubbed so that:

* It no longer constructs an EventSource.
* It logs a single warning in the browser console:
  "[DASHBOARD REFLECTIONS] Reflections SSE backend endpoint not available; wiring is temporarily disabled."

Next steps for a future Phase 11 milestone (e.g., Phase 11.9 – Reflections SSE Backend Alignment):

1. Implement or start the Reflections SSE server so that it exposes a working endpoint returning:
   Content-Type: text/event-stream

2. Use scripts/debug/check_reflections_sse_endpoint.sh to rediscover the correct URL and confirm headers.

3. Once a valid endpoint exists, update public/js/reflections-sse-dashboard.js to restore EventSource wiring, for example:

   * Set REFLECTIONS_SSE_URL to the confirmed URL.
   * Create a new EventSource.
   * Store the latest payload in window.lastReflectionSnapshot.
   * Log events for debugging.

Until those steps are complete, Reflections SSE on the dashboard should be considered "planned but not yet active," and the stubbed wiring avoids noisy console errors while keeping the dashboard otherwise stable.
