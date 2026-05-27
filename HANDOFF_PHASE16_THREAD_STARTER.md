Phase 16 thread starter (from v15.1-disable-optional-sse):

Current:
- Dashboard UI stable, task polling confirmed end-to-end.
- Cosmetic OPS/Reflections SSE noise eliminated by default gate:
  window.__DISABLE_OPTIONAL_SSE = true (dashboard-bundle-entry.js)
  dashboard-status.js / agent-status-row.js / ops-globals-bridge.js bail when set.

Phase 16 Goal:
- Stand up real /events/ops + /events/reflections SSE endpoints (server.mjs or sidecar services),
  then flip gate OFF only when endpoints are live.

First moves:
1) Add minimal SSE routes in server.mjs:
   - GET /events/ops (text/event-stream)
   - GET /events/reflections (text/event-stream)
2) Emit a hello event every ~10–15s (or on real signals) to keep UI alive.
3) Set window.__DISABLE_OPTIONAL_SSE default to false (or delete) once routes exist.
