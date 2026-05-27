# Phase 11.3 — OPS SSE Runtime Log (Post ASCII-safe Rewrite)

## 1) PM2 Restart Check

Commands run:

- pm2 delete ops-sse || true
- pm2 delete reflection-sse-server || true
- kill -9 42773 || true
- kill -9 65128 || true
- kill -9 66077 || true
- lsof -nP -iTCP:3201 || true
- pm2 start ops-sse-server.mjs --name ops-sse
- pm2 ls
- pm2 logs ops-sse --lines 20

Checklist:

- [x] ops-sse shows status: online
- [x] No new "SyntaxError: missing ) after argument list"
- [x] No new "SyntaxError: Invalid or unexpected token"
- [x] Log includes:
  - "✅ OPS SSE server listening on http://localhost:3201/events/ops"
  - "[OPS SSE] listening on http://localhost:3201/events/ops"
- [x] No active EADDRINUSE errors after killing PID 42773 and curl clients

Notes:

- Historical EADDRINUSE lines remained in the error log from earlier restarts.
- After killing the standalone node process and curl clients on 3201, a fresh ops-sse start succeeded cleanly.


## 2) Raw SSE Stream Check (curl)

Command run (in separate terminal):

- curl -N http://127.0.0.1:3201/events/ops

Expected over ~20–30 seconds:

- [x] event: hello      (with "source":"ops-sse")
- [x] event: heartbeat  (every ~5 seconds)
- [x] event: pm2-status (every ~15 seconds)
- [ ] (Optional) event: ops-error if "pm2 jlist" fails

Observed events (sample):

- hello

  - data: {"type":"hello","source":"ops-sse","timestamp":1765230369,"message":"OPS SSE connected"}

- heartbeat (repeated)

  - data: {"type":"heartbeat","timestamp":1765230374,"message":"OPS SSE alive"}
  - data: {"type":"heartbeat","timestamp":1765230379,"message":"OPS SSE alive"}
  - data: {"type":"heartbeat","timestamp":1765230384,"message":"OPS SSE alive"}
  - ...continuing at ~5 second intervals...

- pm2-status (repeated)

  - data: {"type":"pm2-status","timestamp":1765230385,"processes":[{"name":"ops-sse","status":"online","restart_count":0,"cpu":0.3,"memory":54640640}]}
  - data: {"type":"pm2-status","timestamp":1765230400,"processes":[{"name":"ops-sse","status":"online","restart_count":0,"cpu":0.1,"memory":55099392}]}
  - data: {"type":"pm2-status","timestamp":1765230415,"processes":[{"name":"ops-sse","status":"online","restart_count":0,"cpu":0.2,"memory":55754752}]}
  - ...continuing at ~15 second intervals...

- ops-error

  - Not observed during this run.

Notes:

- SSE stream is stable and continuously emitting heartbeat + pm2-status payloads.
- pm2-status snapshots show ops-sse online with low CPU and steadily varying memory usage.


## 3) Status Summary

- [x] Port 3201 is owned solely by the PM2-managed ops-sse process.
- [x] OPS SSE server starts cleanly and stays online.
- [x] hello, heartbeat, and pm2-status events are all confirmed via curl.
- [ ] ops-error behavior still to be observed (only expected on pm2 jlist failure).


## 4) Next Steps

After this runtime check is complete:

- Proceed with dashboard-side verification:

  - Confirm:
    - OPS pill still responds to window.lastOpsHeartbeat.
    - window.lastOpsStatusSnapshot is populated and updates over time.

- Use these docs to drive the remaining checks:

  - PHASE11_OPS_EVENT_STREAM_VERIFICATION.md
  - PHASE11_OPS_SSE_RUNTIME_CHECK.md
  - PHASE11_OPS_SSE_PM2_CHECKLIST.md

Goal:

- Stable ASCII-safe OPS SSE server on port 3201
- Clean pm2-status snapshots flowing into the dashboard
- Ready to tag: v11.3-ops-event-stream-online
