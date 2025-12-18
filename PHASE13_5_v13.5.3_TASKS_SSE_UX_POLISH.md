# Phase 13.5 — Tasks SSE UX Polish (Optional)
Tag baseline: v13.5.3-tasks-sse-keepalive

## Current state (confirmed)
- Tasks SSE is DB-backed, change-detected, and streaming correctly.
- Dashboard uses a hard singleton EventSource shim for /events/tasks.
- Server sends periodic keepalive comment frames; curl confirms stream stability.
- CONNECT / ABORT / CLOSE logs are single-line and de-duplicated.
- Matilda chat is wired and confirmed via /api/chat logs.
- No backend/DB changes planned unless explicitly requested.

## Goal for this mini-pass
Pure UX polish only:
- Reduce noisy reconnect churn.
- Reduce perceived “hiccup” on dashboard boot.
- Avoid any behavioral changes to DB/task logic.

---

## Option A — Reduce keepalive interval (15s → 5s)  [BACKEND TOUCH]
### What it does
- Sends `:keepalive` comment frames more frequently to keep intermediaries from timing out long-lived connections.

### Pros
- Fewer idle timeouts on finicky networks/proxies.
- Faster detection of broken pipes (depending on client/proxy behavior).

### Cons
- Backend change (even if tiny).
- More network chatter (minor).
- If you’re stable at 15s already, benefit may be negligible.

### Recommendation
- Keep 15s unless you have evidence of idle disconnects in real usage.
- Only change if you can point to a concrete stability issue.

### Acceptance test (if changed)
1) `curl -N http://localhost:8080/events/tasks` and confirm keepalive cadence is ~5s.
2) Leave dashboard open 10+ minutes; confirm no reconnect storms.
3) Confirm server logs remain single-line and deduped.

---

## Option B — Stop dashboard-tasks-widget from force-closing EventSource on boot  [FRONTEND ONLY]
### What it does
- Removes “defensive close” on widget init.
- Relies solely on the singleton EventSource shim to enforce one connection.

### Pros
- Cleaner boot: avoids close/reopen loop.
- Less log noise; fewer transient ABORT/CLOSE events.
- Makes the singleton shim the single source of truth.

### Cons
- If the widget currently expects to “reset” the stream state, removing close could reveal a hidden dependency.
- If the singleton shim is ever removed/disabled, you lose the widget-side guardrail.

### Recommendation
- Do this (frontend-only) if the singleton shim is already authoritative and stable.
- Keep a very small safety check:
  - “If a previous EventSource exists AND it is not the singleton-managed instance, do nothing” (preferred)
  - Or simply remove explicit `.close()` calls at startup.

### Acceptance test (if changed)
1) Hard refresh dashboard:
   - Confirm only one CONNECT line for /events/tasks.
   - Confirm no immediate CLOSE/ABORT caused by boot code.
2) Navigate away/back (or re-render widget):
   - Confirm still exactly one active stream.
3) Trigger task mutations:
   - Confirm UI updates still arrive instantly.
4) Leave open 10+ minutes:
   - Confirm no reconnect storms or “stuck” UI.

---

## Implementation notes (where to look)
- Dashboard tasks widget: likely `public/js/dashboard-tasks-widget.js`
  - Search for: `new EventSource(`, `.close()`, `forceClose`, `shutdown`, `cleanup`, `teardown`
- Singleton EventSource shim: the file that overrides/wraps EventSource for `/events/tasks`
  - Search for: `events/tasks`, `EventSource`, `singleton`, `window.EventSource`

---

## Proposed next step order (low-risk first)
1) Implement Option B (frontend-only).
2) Validate with the acceptance tests above.
3) Only consider Option A if you observe idle disconnects in real usage.

---

## Guardrails
- Do not change server/DB/task logic.
- Do not introduce new reconnect loops.
- If any UX change increases log noise or reconnect churn, revert immediately to v13.5.3 behavior.
