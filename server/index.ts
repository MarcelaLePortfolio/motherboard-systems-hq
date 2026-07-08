import { mountApiUiCompat } from "./routes/api-ui-compat";
import taskEventsRouter from "./routes/task-events-sse.mjs";
import { mountApiCompat } from "./routes/api-compat";

import express from "express";

import cors from "cors";

import cadeRouter from "./routes/cade";

import atlasRouter from "./routes/atlas/why";

import { getEvents } from "./events/execution-event-bus";

import { mountDashboard } from "./static-mount";

const app = express();

app.use(cors());

app.use(express.json());

// 🔹 Dashboard (IMPORTANT FIX)

mountDashboard(app);

// Core systems

app.use(cadeRouter);

app.use(atlasRouter);
app.use(taskEventsRouter);

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


// mountApiCompat(app);



mountApiUiCompat(app);
