# Phase 16 – OPS/Tasks Heartbeat + Stale Indicator

## Branch
feature/phase16-ops-heartbeat

## Key Tags
- v16.0-heartbeat-shim-wired
- v16.1-heartbeat-verify-timeout-safe
- v16.2-heartbeat-stale-indicator
- v16.3-heartbeat-sse-header-confirmed
- v16.4-heartbeat-open-recorded
- v16.5-ops-heartbeat-pinger
- v16.6-heartbeat-badge-hb-ok

## What Changed
- EventSource heartbeat shim: window.__HB captures heartbeat for SSE streams (ops/tasks).
- Heartbeat badge: non-intrusive fixed badge shows HB ✓ / HB ! with ages.
- Ops heartbeat pinger: /api/ops-heartbeat + /api/heartbeat endpoints; dashboard pings ops so it never looks dead.

## Quick Checks
- Dashboard: http://127.0.0.1:8080/dashboard
- Heartbeat JSON: GET /api/heartbeat
- Ops ping: GET /api/ops-heartbeat
- Tasks SSE: GET /events/tasks

## Next High-ROI Work
- Replace ops pinger with real OPS SSE (if desired) and wire badge to real stream.
- Add toast/badge escalation when stale persists > N seconds.
- Add “Last updated” per-widget display (Tasks + OPS pill) sourced from the shared heartbeat.
