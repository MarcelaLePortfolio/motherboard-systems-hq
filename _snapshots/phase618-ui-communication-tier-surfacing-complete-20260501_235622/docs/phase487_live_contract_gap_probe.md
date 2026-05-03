# Phase 487 Live Contract Gap Probe

Generated: Tue Apr 21 11:18:41 PDT 2026

## Safe live probes

- GET /api/health -> 200
- GET /api/tasks -> 200
- GET /api/runs -> 200
- GET /api/guidance -> 200
- GET /diagnostics/system-health -> 200
- GET /events/ops -> 200
- GET /events/reflections -> 200
- GET /events/tasks -> 200
- GET /events/task-events -> 200
- GET /api/chat -> 404
- GET /api/delegate-task -> 404

## Repo route ownership scan

```
server.mjs:192:app.use("/diagnostics/system-health", systemHealthRouter);
server.mjs:374:app.post("/api/delegate-task", async (req, res) => {
server.mjs:411:app.get("/events/tasks", async (req, res) => {
server.mjs:650:  app.get("/events/ops", (req, res) => {
server.mjs:784:app.use("/api/guidance", apiGuidanceRouter);
server.mjs:789:app.use("/api/guidance", apiGuidanceRouter);
server/optional-sse.mjs:172:  app.get("/events/ops", ops.handler);
server/optional-sse.mjs:173:  app.get("/events/reflections", reflections.handler);
scripts/_local/route-loader/ops-sse-server.ts:12:app.get("/events/ops", (req, res) => {
scripts/_local/route-loader/reflection-sse-server.ts:12:app.get("/events/reflections", (req, res) => {
```

## Current interpretation

- Read-only health/guidance/tasks/runs surfaces are live if they return 200.
- Matilda chat and delegation are UI contract candidates only if source routes exist in repo.
- SSE routes are considered live only if backend route ownership exists and GET does not 404.
