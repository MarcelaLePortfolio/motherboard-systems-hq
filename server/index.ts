
import { mountRootRedirect } from "./routes/root-redirect";

import sseRouter from "./routes/sse";

import { mountMinimalUI } from "./routes/minimal-ui";

import { mountApiUiCompat } from "./routes/api-ui-compat";

import taskEventsRouter from "./routes/task-events-sse.mjs";

import { mountApiCompat } from "./routes/api-compat";

import express from "express";

import cors from "cors";

import cadeRouter from "./routes/cade";

import atlasRouter from "./routes/atlas/why";

import eventsSurfaceRouter from "./routes/events-surface";

import { getEvents } from "./events/execution-event-bus";

import { mountDashboard } from "./static-mount";

const app = express();

app.use(cors());

app.use(express.json());

// 🔹 Dashboard

mountDashboard(app);

// Core systems

app.use(cadeRouter);

app.use(atlasRouter);

app.use(taskEventsRouter);

// ✅ STATE SURFACE LAYER (NEW)

app.use(eventsSurfaceRouter);

// Health check

app.get("/health", (_, res) => {

  res.json({ status: "ok", runtime: "active" });

});

// Event debug

app.get("/events", (_, res) => {

  res.json(getEvents());

});

const PORT = 3000;

app.listen(PORT, () => {

  console.log(`🚀 System runtime active on http://localhost:${PORT}`);

});

mountApiUiCompat(app);

mountMinimalUI(app);

app.use(sseRouter);

// temporary SSE heartbeat

import { emitSSE } from "./events/sse-bus";

setInterval(() => {

  emitSSE("ops", { type: "heartbeat", source: "ops", message: "heartbeat" });

  emitSSE("reflections", { type: "heartbeat", source: "reflections", message: "heartbeat" });

}, 3000);

mountRootRedirect(app);

