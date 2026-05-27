
Phase 11.3 — OPS Dashboard Verification Handoff
0) Context

Branch: feature/v11-dashboard-bundle
Backend baseline: v11.2-ops-sse-online
Current work: Phase 11.3 — real OPS event stream (hello, heartbeat, pm2-status, ops-error)

Status so far:

ops-sse-server.mjs:

ASCII-safe implementation.

Emits:

event: hello

event: heartbeat (every ~5s)

event: pm2-status (every ~15s)

event: ops-error on pm2 failure (not yet observed, by design).

Verified via:

PHASE11_OPS_SSE_RUNTIME_LOG.md

PHASE11_OPS_SSE_PORT_RESET_LOG.md

PM2:

ops-sse managed and online.

Port 3201 confirmed owned solely by ops-sse.

Next goal:

Verify that the dashboard UI (local and optionally container) correctly consumes:

window.lastOpsHeartbeat → OPS pill state.

window.lastOpsStatusSnapshot → pm2 snapshots.

Confirm no regressions introduced by real pm2-status events.

Use this handoff in a new thread to guide the dashboard verification and tagging.

1) Runtime Pre-check (OPS SSE)

In a terminal:

Ensure repo and branch:

cd /Users/marcela-dev/Projects/Motherboard_Systems_HQ

git status

On branch: feature/v11-dashboard-bundle

Working tree: clean

Confirm ops-sse status:

pm2 ls

Expect:

ops-sse → online

Optional: recheck raw SSE stream:

curl -N http://127.0.0.1:3201/events/ops

Over ~20–30 seconds, expect:

event: hello

event: heartbeat (every ~5s)

event: pm2-status (every ~15s)

event: ops-error only if pm2 jlist fails

If all looks good, proceed to dashboard checks.

2) Local Dashboard — Heartbeat & OPS Pill

In a separate terminal:

Start the local server (if not already running):

cd /Users/marcela-dev/Projects/Motherboard_Systems_HQ

node server.mjs

In the browser:

Open: http://localhost:3000

Open DevTools → Console tab.

In the console, run:

window.lastOpsHeartbeat

If defined, optionally:

new Date(window.lastOpsHeartbeat).toISOString()

Optionally paste the helper snippet:

setInterval(() => {
  console.log(
    "[OPS DEBUG] lastOpsHeartbeat:",
    window.lastOpsHeartbeat,
    window.lastOpsHeartbeat
      ? new Date(window.lastOpsHeartbeat).toISOString()
      : "(null)"
  );
}, 5000);


Checklist:

window.lastOpsHeartbeat becomes defined shortly after page load.

Value updates over time.

No console errors related to OPS SSE / heartbeat.

Then visually confirm the OPS pill:

ONLINE when heartbeat is fresh (< ~15s).

STALE/NO SIGNAL behavior remains correct if ops-sse is stopped (optional test).

No new styling or layout regressions in the OPS tile.

Record results in:

PHASE11_OPS_DASHBOARD_VERIFICATION_LOG.md — section 2.

3) Local Dashboard — pm2-status Snapshot

In the same browser console:

Check snapshot object:

window.lastOpsStatusSnapshot

Expect structure similar to:

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


Optionally paste helper snippet:

setInterval(() => {
  console.log("[OPS DEBUG] lastOpsStatusSnapshot:", window.lastOpsStatusSnapshot);
}, 15000);


Checklist:

window.lastOpsStatusSnapshot becomes defined.

timestamp changes over time (~15s cadence).

processes array includes "ops-sse" with plausible CPU/memory.

No console errors when snapshots arrive.

Confirm:

OPS pill still depends only on heartbeat and behaves as before.

pm2-status snapshots do not cause pill flicker or incorrect labels.

Record results in:

PHASE11_OPS_DASHBOARD_VERIFICATION_LOG.md — section 3.

4) Optional — Container Dashboard Verification

If desired, verify the containerized dashboard:

In a terminal:

cd /Users/marcela-dev/Projects/Motherboard_Systems_HQ

docker-compose up dashboard -d

In the browser:

Open: http://localhost:8080

Open DevTools → Console tab.

Repeat:

Heartbeat checks for window.lastOpsHeartbeat.

pm2 snapshot checks for window.lastOpsStatusSnapshot.

Visual OPS pill verification.

Record results in:

PHASE11_OPS_DASHBOARD_VERIFICATION_LOG.md — section 4.

5) Tagging v11.3-ops-event-stream-online

Once:

OPS SSE backend is stable (confirmed by curl + PM2 logs).

Local dashboard:

OPS pill = correct.

window.lastOpsHeartbeat = correct.

window.lastOpsStatusSnapshot = correct and updating.

(Optional) Container dashboard passes the same checks.

Then:

Update summary section in:

PHASE11_OPS_DASHBOARD_VERIFICATION_LOG.md — section 5.

Create the new golden tag:

git tag v11.3-ops-event-stream-online
git push origin v11.3-ops-event-stream-online


This tag becomes the new baseline for:

Real OPS telemetry via SSE.

Dashboard awareness of pm2 status via window.lastOpsStatusSnapshot.

Unchanged OPS pill behavior via window.lastOpsHeartbeat.

6) Next Phase Options After Tagging

Once v11.3-ops-event-stream-online is established, you can branch into:

Phase 11.4 — Visual OPS Snapshot Widget

Turn lastOpsStatusSnapshot into a compact UI element in the OPS tile.

Phase 11.5 — DB-Backed Task Pipeline

Start wiring real task persistence (still intentionally deferred so far).

How to Use This Handoff in a New Thread

Say:

“Pick up from PHASE11_OPS_DASHBOARD_VERIFICATION_HANDOFF.md — guide me through local dashboard heartbeat + pm2-status checks, then help me decide when to tag v11.3-ops-event-stream-online.”

