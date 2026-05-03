# Phase 628 Task Events SSE Check

## Route probe
HTTP/1.1 200 OK
X-Powered-By: Express
Content-Type: text/event-stream; charset=utf-8
Cache-Control: no-cache, no-transform
Connection: keep-alive
X-Accel-Buffering: no
Date: Sun, 03 May 2026 23:54:34 GMT
Transfer-Encoding: chunked

event: error
data: {"kind":"task-events","msg":"task-events stream bootstrap error","detail":"column \"ts\" does not exist","ts":1777852474174,"cursor":0}


## Server route references
server/task_events_emit.mjs:1:import { appendTaskEvent } from "./task-events.mjs";
server/api/tasks-mutations/delegate-taskspec.mjs:28: * - Inserts into task_events(kind="task.created") so /events/task-events advances
server/routes/phase40_6_shadow_audit_task_events.mjs:5:  app.get("/api/shadow/audit/task-events", async (req, res) => {
server/routes/phase40_6_shadow_audit_task_events.mjs:39:        scope: "phase40.6.shadow-audit.task-events",
server/routes/phase40_6_shadow_audit_task_events.mjs:48:        scope: "phase40.6.shadow-audit.task-events",
server/routes/task-events-sse.mjs:83:router.get("/api/task-events-sse", (req, res) => {
server/routes/task-events-sse.mjs:84:  res.redirect(307, "/events/task-events");
server/routes/task-events-sse.mjs:87:router.get("/events/task-events", async (req, res) => {
server/routes/task-events-sse.mjs:109:        kind: "task-events",
server/routes/task-events-sse.mjs:144:        kind: "task-events",
server/routes/task-events-sse.mjs:210:            kind: "task-events",
server/routes/task-events-sse.mjs:211:            msg: "task-events stream error",
server/routes/task-events-sse.mjs:238:        kind: "task-events",
server/routes/task-events-sse.mjs:239:        msg: "task-events stream bootstrap error",
server.js:9:import taskEventsSseRouter from "./server/routes/task-events-sse.mjs";
server.mjs:9:import taskEventsSseRouter from "./server/routes/task-events-sse.mjs";
public/js/task-events-sse-client.js:2:  const STREAM_URL = "/events/task-events?cursor=0";
public/js/task-events-sse-client.js:3:  const ROOT_ID = "mb-task-events-panel-anchor";
