Phase 15 follow-up: optional OPS + Reflections SSE listeners are now formally disabled behind a global gate.

Change:
- public/js/dashboard-bundle-entry.js sets window.__DISABLE_OPTIONAL_SSE = true by default.
- dashboard-status.js, agent-status-row.js, ops-globals-bridge.js bail early when __DISABLE_OPTIONAL_SSE is true.
Result:
- No EventSource attempts for /events/ops or /events/reflections, eliminating cosmetic 404 noise until Phase 16 backends exist.
Branch:
- fix/disable-ops-reflections-sse-until-phase16 (commit 815fbfa3) pushed.
Next:
- When Phase 16 starts, either remove the default flag or set it false only when OPS/Reflections SSE servers are live.
