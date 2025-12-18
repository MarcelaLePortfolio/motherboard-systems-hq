# Phase 13.5 — v13.5.4-ux-no-force-close Handoff

## What changed
- Removed dashboard-tasks-widget boot-time force-close of EventSource.
- Now relies solely on the hard singleton EventSource shim for /events/tasks.

## Verification
- Server logs show:
  - CONNECT=2 (browser + curl)
  - CLOSE=0
  - ABORT=0
- Tasks SSE stream stable via curl.

## Tags
- Baseline: v13.5.3-tasks-sse-keepalive
- UX checkpoint: v13.5.4-ux-no-force-close

## Optional next
- Decide whether to normalize keepalive frames (": hb" vs ":keepalive") for cleaner curl output.
- Keepalive interval change (15s→5s) remains optional; no evidence it’s needed.
