
# Phase 11.3 — OPS Event Stream Verification Log

## Context

* Branch: `feature/v11-dashboard-bundle`
* Baseline tag: `v11.2-ops-sse-online`
* New work:

  * `ops-sse-server.mjs` now emits:

    * `hello`
    * `heartbeat`
    * `pm2-status`
    * `ops-error` (on PM2 snapshot failure)
  * `public/js/ops-sse-listener.js` now:

    * Maintains `window.lastOpsHeartbeat`
    * Maintains `window.lastOpsStatusSnapshot`
    * Logs `pm2-status` and `ops-error` to the browser console
  * `public/bundle.js` rebuilt successfully and served on the dashboard

This file is the checklist + scratchpad for verifying that real OPS telemetry is online and stable before tagging.

---

## 1) Local SSE Sanity Check (Terminal)

### Command

Run this in a terminal with `ops-sse` running under PM2:

```bash
curl -N http://127.0.0.1:3201/events/ops
```

Hit **Ctrl-C** after you’ve seen a few cycles.

### Expected

You should see, in order over time:

* A `hello` event when the connection opens, for example:

  ```text
  event: hello
  data: {"type":"hello","source":"ops-sse","timestamp":..., "message":"OPS SSE connected"}
  ```

* Repeating `heartbeat` events every ~5 seconds:

  ```text
  event: heartbeat
  data: {"type":"heartbeat","timestamp":..., "message":"OPS SSE alive"}
  ```

* Repeating `pm2-status` events every ~15 seconds:

  ```text
  event: pm2-status
  data: {"type":"pm2-status","timestamp":..., "processes":[...]}
  ```

* If PM2 status fails, you may see:

  ```text
  event: ops-error
  data: {"type":"ops-error","source":"pm2-status",...}
  ```

### Result

* [ ] `hello` event appears
* [ ] `heartbeat` at ~5s cadence
* [ ] `pm2-status` appears with JSON payload (not just heartbeats)
* [ ] No obviously malformed JSON
* [ ] No stack traces or fatal errors in `pm2 logs ops-sse`

Notes:

* *Example:* `pm2-status shows matilda, cade, effie with accurate status...`
* *Example:* `ops-error never emitted during this check...`

---

## 2) Local Dashboard Verification (Port 3000)

### Steps

1. In another terminal, ensure the main server is running:

   ```bash
   node server.mjs
   ```

2. Open the local dashboard in the browser:

   * URL: `http://localhost:3000`

3. Open **DevTools → Console**.

### Expected

* No new JS errors related to:

  * `ops-sse-listener.js`
  * `EventSource`
  * JSON parsing for `pm2-status`
* In the console logs:

  * A one-time:
    `"[OPS SSE] Connection opened to http://127.0.0.1:3201/events/ops"`
  * Periodic logs of pm2 snapshots, e.g.:
    `"[OPS pm2-status]" { ...process list... }`
  * Heartbeats are not logged (by design) but still drive:

    * OPS status pill behavior.

### OPS Pill Behavior

* When OPS SSE server is running:

  * Pill should show **ONLINE** (or transition briefly through **STALE** if the tab is backgrounded).
* If you stop OPS SSE server:

  * Pill should eventually move to **STALE** or **NO SIGNAL** depending on your existing logic (unchanged from baseline).

### Result

* [ ] No new JS console errors
* [ ] `window.lastOpsHeartbeat` is updating (inspect via console)
* [ ] `window.lastOpsStatusSnapshot` exists and updates over time
* [ ] OPS pill behaves as before (no regressions, still reflects heartbeat freshness)

Notes:

* *Example:* `lastOpsStatusSnapshot.processes includes matilda/cade/effie with expected states...`

---

## 3) Container Dashboard Verification (Port 8080)

> Only run this section when you’re ready to verify the containerized stack.

### Steps

1. Start the docker stack (from project root):

   ```bash
   docker-compose up -d
   ```

2. Open the container dashboard:

   * URL: `http://localhost:8080`

3. Open DevTools → Console.

### Expected

* Same behavior as local dev:

  * No JS errors.
  * `pm2-status` logs visible.
  * OPS pill behavior unchanged.
* No CORS errors for `/events/ops`.

### Result

* [ ] Container dashboard loads without error
* [ ] `pm2-status` logs visible in console
* [ ] OPS pill still functional and accurate
* [ ] No CORS / network errors for `/events/ops`

Notes:

* *Example:* `Container dashboard shows same set of processes as local...`

---

## 4) Stability Observation (Optional but Recommended)

Spend a few minutes with:

* The local dashboard open.
* (Optionally) The container dashboard open.
* PM2 logs tailing in a terminal:

```bash
pm2 logs ops-sse --lines 50
```

Verify:

* [ ] No recurring `Error fetching PM2 status` spam.
* [ ] No obvious runaway CPU or memory usage for `ops-sse`.
* [ ] SSE does not crash when:

  * You refresh the dashboard repeatedly.
  * You close and reopen the tab.

Notes:

* *Example:* `pm2 logs show occasional ops-error when pm2 jlist hiccups, but server recovers...`

---

## 5) Tagging Instructions (Only After Manual Confirmation)

Once all checkboxes above are satisfied for at least the local dashboard (and ideally also the container dashboard):

1. Create the new stable tag:

   ```bash
   git tag v11.3-ops-event-stream-online
   git push origin v11.3-ops-event-stream-online
   ```

2. Treat this tag as the new golden baseline for:

   * Real OPS telemetry via SSE.
   * Dashboard awareness of `pm2-status` (via `window.lastOpsStatusSnapshot`).
   * Unchanged OPS status pill behavior tied to `window.lastOpsHeartbeat`.

---

## 6) Next Steps After Tagging (Future Phase Options)

After `v11.3-ops-event-stream-online` is confirmed, you can branch into:

* **Phase 11.4 — Visual OPS Snapshot Widget**

  * Turn `lastOpsStatusSnapshot` into a compact UI element in the OPS tile.

* **Phase 11.5 — DB-Backed Task Pipeline**

  * Begin wiring real task persistence (currently deferred on purpose).

When starting a new thread, you can say:

> “Resume from Phase 11.3 verified baseline at v11.3-ops-event-stream-online. Next, help me build a minimal visual widget for lastOpsStatusSnapshot.”

