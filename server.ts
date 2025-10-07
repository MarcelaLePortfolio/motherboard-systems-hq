// <0001fbC1> Serve real dashboard layout from public/
import express from "express";
import reflectionsRouter from "./scripts/api/reflections-router";
import matildaRouter from "./scripts/api/matilda-router";
import statusRouter from "./scripts/api/status-router";
import tasksRouter from "./scripts/api/tasks-router";
import logsRouter from "./scripts/api/logs-router";
import path from "path";

const app = express();
const publicDir = path.resolve("public");
app.use(express.static(publicDir));
console.log(`📂 Serving static files from ${publicDir}`);

app.use("/api/reflections", reflectionsRouter);
app.use("/matilda", matildaRouter);
app.use("/status", statusRouter);
app.use("/tasks", tasksRouter);
app.use("/logs", logsRouter);

// ✅ Redirect /dashboard → /dashboard.html
app.get("/dashboard", (_req, res) => res.sendFile(path.join(publicDir, "dashboard.html")));

app.use((_req, res) => res.status(404).send("<h1>404 – Page not found</h1>"));

const PORT = process.env.PORT || 3001;
app.listen(PORT, () => console.log(`🚀 Express server running at http://localhost:${PORT}`));
