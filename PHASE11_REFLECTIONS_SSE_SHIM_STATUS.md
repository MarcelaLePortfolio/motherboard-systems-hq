# Phase 11 – Reflections SSE Shim & Backend Status (v11.9)

## Context

- Branch: feature/v11-dashboard-bundle
- Goal: Keep dashboard stable while Reflections SSE backend is not yet wired for production use.
- Current behavior: A JS shim overrides window.EventSource and returns a dummy EventSource for any URL containing "events/reflections".

## Known Reflections-Related Files (discovery – v11.9)

From repo root:

- reflection_index.ts
- reflection-loader.ts
- reflection-push.ts
- reflection-sse-lite.ts
- reflection-sse-server.ts
- reflection-watcher.ts
- reflections-sse-server.ts
- reflections.ts
- reflections-stream/
  - reflections_stream.py
  - requirements.txt

Notes:

- Multiple TypeScript entrypoints exist for Reflections-related streaming (lite/server variants).
- A Python prototype also exists under reflections-stream/, but current Phase 11 focus is on the Node/TS pipeline.
- Actual wiring of the *live* Reflections SSE endpoint is deferred until a later Phase 11.x.

## Current Shim Behavior (sse-reflections-shim.js – v11.9)

The shim:

- Wraps window.EventSource in the browser.
- Intercepts any URL string containing "events/reflections".
- Logs a console warning:
  - "[SSE SHIM] Reflections SSE disabled; backend not available. Returning dummy EventSource."
- Returns a dummy EventSource-like object:
  - Implements close(), onmessage, onerror, addEventListener(), removeEventListener(), dispatchEvent().
  - dispatchEvent() always returns false.
- For all other URLs:
  - Falls back to the native EventSource implementation.

Impact on dashboard:

- Any attempt to connect to `/events/reflections` will be safely no-op, avoiding browser console noise and failing connections during development while the backend is offline.
- OPS SSE (e.g., `/events/ops`) is unaffected and should continue to function normally.

## Intended Final Wiring (for later Phase 11.x)

Target behavior (once backend is ready):

- A dedicated Reflections SSE server process will expose:
  - Endpoint: `/events/reflections`
  - Host: `127.0.0.1`
  - Port: `3200` (as used in prior local testing with EventSource).
- Dashboard client:
  - Uses `new EventSource("http://127.0.0.1:3200/events/reflections")` or a relative URL when proxied via the main server.
- Reflections server code:
  - Implemented via one of the existing TS entrypoints (e.g., `reflections-sse-server.ts` or `reflection-sse-server.ts`) after final selection and cleanup.
  - Responsible for pushing reflection log updates in SSE format to the dashboard.

The shim will be **removed or disabled** once:

1. The Reflections SSE server is stable locally (no crashes, correct payloads).
2. The dashboard’s Reflections UI consumer is verified to handle reconnects and empty streams gracefully.
3. We have a new stable tag (e.g., `v11.x-reflections-sse-online`) capturing the working configuration.

## v11.9 Plan – Shim & Backend Prep

For v11.9 specifically:

- Keep the shim **enabled** to avoid dashboard breakage while working on other Phase 11 tasks (dashboard reliability, Matilda Chat UX).
- Ensure the shim implementation is syntactically valid JS and safe to load in all environments.
- Treat this doc as the single source of truth for Reflections SSE shim state until a later activation phase.

## Phase 11.10 – Reflections SSE Activation Checklist (Draft)

Before removing or bypassing the shim:

1. **Backend Availability**
   - A chosen Reflections SSE server file (e.g., `reflections-sse-server.ts`) is:
     - Compiled and runnable under the current Node/TS toolchain.
     - Exposed on `http://127.0.0.1:3200/events/reflections` (or equivalent proxied URL).
   - Manual test:
     - `curl -N http://127.0.0.1:3200/events/reflections`
     - Confirm a valid SSE stream: `data: ...` lines, connection stays open.

2. **Dashboard Integration**
   - The dashboard JavaScript uses a standard `new EventSource()` call for Reflections without being intercepted by the shim:
     - No shim blocking on `/events/reflections`.
   - Browser console:
     - No connection errors for `/events/reflections` beyond expected network conditions.
     - No shim warning logs.

3. **UI Behavior**
   - Reflections-related UI elements (e.g., logs/stream panels) update in real-time without freezing or causing layout shifts.
   - Fast refresh + reload tests:
     - Multiple hard refreshes do not spawn unbounded EventSource connections.
     - Closing/reopening the dashboard doesn’t leave zombie connections.

4. **Stability & Tagging**
   - The system runs under normal dev workflow for a reasonable period with:
     - OPS SSE + Reflections SSE both online.
   - Create and push a stable tag, for example:
     - `v11.10-reflections-sse-online-stable`

Once all of the above are satisfied, the shim file can either be:

- Removed entirely from the bundle / script tags, or
- Left in place but configured so that it does **not** intercept `/events/reflections` in the active configuration.

