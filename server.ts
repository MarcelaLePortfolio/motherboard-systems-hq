// <0001fbC1> Serve real dashboard layout from public/
import express from "express";
import cadeRouter from "./scripts/api/cade-router";
import opsRouter from "./scripts/api/ops-router";
import insightRouter from "./scripts/api/insight-router";
import reflectionsRouter from "./scripts/api/reflections-router";
import matildaRouter from "./scripts/api/matilda-router";
import statusRouter from "./scripts/api/status-router";
import tasksRouter from "./scripts/api/tasks-router";
import logsRouter from "./scripts/api/logs-router";
import path from "path";

const app = express();
app.use(express.json());
const publicDir = path.resolve("public");
app.use(express.static(publicDir));
app.use("/ops", opsRouter);
app.use("/insights", insightRouter);
app.use("/cade", cadeRouter);
app.use("/insights", insightRouter);
app.use("/cade", cadeRouter);
console.log(`📂 Serving static files from ${publicDir}`);

app.use("/api/reflections", reflectionsRouter);
app.use("/ops", opsRouter);
app.use("/insights", insightRouter);
app.use("/cade", cadeRouter);
app.use("/insights", insightRouter);
app.use("/cade", cadeRouter);
app.use("/matilda", matildaRouter);
app.use("/ops", opsRouter);
app.use("/insights", insightRouter);
app.use("/cade", cadeRouter);
app.use("/insights", insightRouter);
app.use("/cade", cadeRouter);
app.use("/status", statusRouter);
app.use("/ops", opsRouter);
app.use("/insights", insightRouter);
app.use("/cade", cadeRouter);
app.use("/insights", insightRouter);
app.use("/cade", cadeRouter);
app.use("/tasks", tasksRouter);
app.use("/ops", opsRouter);
app.use("/insights", insightRouter);
app.use("/cade", cadeRouter);
app.use("/insights", insightRouter);
app.use("/cade", cadeRouter);
app.use("/logs", logsRouter);
app.use("/ops", opsRouter);
app.use("/insights", insightRouter);
app.use("/cade", cadeRouter);
app.use("/insights", insightRouter);
app.use("/cade", cadeRouter);

// ✅ Redirect /dashboard → /dashboard.html
app.get("/dashboard", (_req, res) => res.sendFile(path.join(publicDir, "dashboard.html")));

app.use((_req, res) => res.status(404).send("<h1>404 – Page not found</h1>"));
app.use("/ops", opsRouter);
app.use("/insights", insightRouter);
app.use("/cade", cadeRouter);
app.use("/insights", insightRouter);
app.use("/cade", cadeRouter);

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`🚀 Express server running at http://localhost:${PORT}`));
