# Phase 13.5 — v13.5.5-ux-keepalive-clean Handoff

## What changed since v13.5.3
1) UX: dashboard-tasks-widget no longer force-closes EventSource on boot.
   - Relies on the singleton EventSource shim for /events/tasks.
2) UX: tasks SSE keepalive frames normalized:
   - Removed duplicate ": hb" interval
   - Keepalive now writes a proper SSE comment frame (":keepalive" + blank line), no literal "\n\n"

## Verification
- Server logs show browser + curl CONNECT cleanly; no boot-trigger CLOSE/ABORT observed.
- `curl -N http://127.0.0.1:8080/events/tasks` prints:
  - `: ready`
  - one initial `data: {...}` snapshot
  - periodic `:keepalive` comment frames (every 15s)

## Tags
- v13.5.3-tasks-sse-keepalive (baseline)
- v13.5.4-ux-no-force-close (widget boot behavior)
- v13.5.5-ux-keepalive-clean (keepalive formatting + no hb spam)

## Optional next (pure UX)
- Decide whether to reduce keepalive interval (15s → 5s). Not needed unless you see idle disconnects.
