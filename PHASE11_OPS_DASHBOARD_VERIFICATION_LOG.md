
# Phase 11.3 — OPS Dashboard Verification Log

## 0) Context

Branch: feature/v11-dashboard-bundle

Backend status:

* OPS SSE server:

  * Managed by PM2 as "ops-sse"
  * Listening at: [http://localhost:3201/events/ops](http://localhost:3201/events/ops)
  * Confirmed via curl:

    * event: hello
    * event: heartbeat (every ~5s)
    * event: pm2-status (every ~15s)

Goal of this log:

* Verify that the **dashboard UI** correctly consumes:

  * `window.lastOpsHeartbeat`  (OPS pill state)
  * `window.lastOpsStatusSnapshot` (pm2 snapshots)
* Confirm that enabling real pm2-status events did **not** break the OPS pill behavior.

## 1) Local Dashboard — Runtime Setup

### 1.1 Start local server (if not already running)

In a separate terminal:

* cd /Users/marcela-dev/Projects/Motherboard_Systems_HQ
* node server.mjs

Confirm:

* Dashboard loads at: [http://localhost:3000](http://localhost:3000)

Notes:

### 1.2 Open dashboard and DevTools

1. Visit: [http://localhost:3000](http://localhost:3000)
2. Open browser DevTools → Console tab.

Notes:

## 2) heartbeat → OPS Pill Verification

### 2.1 Check `window.lastOpsHeartbeat`

In the browser console, run:

* `window.lastOpsHeartbeat`
* `new Date(window.lastOpsHeartbeat).toISOString()` (if defined)

Checklist:

* [ ] `window.lastOpsHeartbeat` is defined after page load + a few seconds.
* [ ] Value updates over time (re-run `window.lastOpsHeartbeat` every ~10s).
* [ ] No console errors related to OPS SSE or heartbeat.

Optional helper snippet (paste in console):

```js
setInterval(() => {
  console.log(
    "[OPS DEBUG] lastOpsHeartbeat:",
    window.lastOpsHeartbeat,
    window.lastOpsHeartbeat ? new Date(window.lastOpsHeartbeat).toISOString() : "(null)"
  );
}, 5000);
```

Notes:

### 2.2 OPS Pill Behavior

Observe the OPS status pill on the dashboard:

* It should still follow the original rules:

  * ONLINE → heartbeat < 15s old
  * STALE → heartbeat older than 15s
  * NO SIGNAL → no heartbeat yet

Checklist:

* [ ] Pill shows "ONLINE" when SSE is connected and heartbeats are flowing.
* [ ] If you stop ops-sse (optional test), pill eventually reflects **STALE** or **NO SIGNAL**.
* [ ] No visual regressions in the OPS tile.

Notes:

## 3) pm2-status → Dashboard Snapshot Verification

### 3.1 Check `window.lastOpsStatusSnapshot`

In the browser console, run:

* `window.lastOpsStatusSnapshot`

Expect something like:

```js
{
  type: "pm2-status",
  timestamp: 1765230385,
  processes: [
    {
      name: "ops-sse",
      status: "online",
      restart_count: 0,
      cpu: 0.1,
      memory: 55099392
    }
  ]
}
```

Checklist:

* [ ] `window.lastOpsStatusSnapshot` becomes defined after a few seconds.
* [ ] `window.lastOpsStatusSnapshot.timestamp` changes over time (~15s cadence).
* [ ] `window.lastOpsStatusSnapshot.processes` is an array with at least "ops-sse".
* [ ] No console errors when pm2 snapshots arrive.

Optional helper snippet:

```js
setInterval(() => {
  console.log("[OPS DEBUG] lastOpsStatusSnapshot:", window.lastOpsStatusSnapshot);
}, 15000);
```

Notes:

### 3.2 Interaction with OPS Pill

Verify:

* [ ] OPS pill still relies **only** on `window.lastOpsHeartbeat`.
* [ ] Injecting pm2-status snapshots does **not** cause pill flicker or wrong labeling.
* [ ] No unexpected UI updates or layout shifts in the OPS tile.

Notes:

## 4) Optional — Container Dashboard Verification

If you want to verify the containerized dashboard as well:

Commands (in another terminal):

* `docker-compose up dashboard -d`
* Visit: [http://localhost:8080](http://localhost:8080)

Then repeat:

* Sections 2 and 3 for the container dashboard.
* Confirm that both heartbeat and pm2-status behavior are consistent with local dev.

Checklist:

* [ ] Container dashboard loads without JS errors.
* [ ] OPS pill behavior matches local.
* [ ] `window.lastOpsStatusSnapshot` is populated and updates.

Notes:

## 5) Summary & Tagging Readiness

Once all above checks are complete:

Status:

* [ ] Local dashboard:

  * [ ] OPS pill OK
  * [ ] lastOpsHeartbeat OK
  * [ ] lastOpsStatusSnapshot OK
* [ ] Container dashboard (optional):

  * [ ] OPS pill OK
  * [ ] lastOpsHeartbeat OK
  * [ ] lastOpsStatusSnapshot OK

If everything passes:

* It is safe to proceed toward tagging:

  * `v11.3-ops-event-stream-online`

Tagging commands (for later, once you’re satisfied):

* `git tag v11.3-ops-event-stream-online`
* `git push origin v11.3-ops-event-stream-online`

Final notes:

