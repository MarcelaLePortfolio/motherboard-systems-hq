
Phase 11 – OPS SSE Temporarily Disabled

Console errors:

EventSource MIME type: "text/html" instead of "text/event-stream"

"[OPS SSE] EventSource setup failed"

Root cause:

/events/ops currently returns an HTML response (likely 404/error), not an SSE stream.

v11.10 decision:

Remove EventSource wiring from the dashboard bundle.

Keep OPS pill rendered as static "OPS: Unknown" until a proper SSE backend is implemented.

Future fix:

Implement real SSE endpoint at /events/ops with:

Content-Type: text/event-stream

Streaming JSON status payloads

Re-enable EventSource logic in dashboard-bundle-entry.js after backend is ready.
