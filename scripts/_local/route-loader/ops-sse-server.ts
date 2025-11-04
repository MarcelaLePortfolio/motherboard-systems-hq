// <0001fae6> Phase 6.1 — OPS SSE fallback-safe schema patch
import express from "express";
import { sqlite } from "../../../db/client";

const app = express();
const PORT = 3201;

console.log(`🧩 OPS Bootstrap — Verifying schema at: ${process.cwd()}/db/main.db`);
sqlite.prepare(
  `CREATE TABLE IF NOT EXISTS task_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    description TEXT,
    status TEXT DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    event_type TEXT DEFAULT 'task',
    agent TEXT
  )`
).run();
console.log("✅ task_events table confirmed for OPS SSE runtime");

const sendOps = () => {
  try {
    const reflections = sqlite
      .prepare("SELECT id, content, created_at FROM reflection_index ORDER BY created_at DESC LIMIT 5")
      .all();
    const tasks = sqlite
      .prepare("SELECT id, description, status, created_at FROM task_events ORDER BY created_at DESC LIMIT 5")
      .all();
    const payload = { reflections, tasks, ts: new Date().toISOString() };
    app.locals.clients.forEach((res: any) => res.write(`data: ${JSON.stringify(payload)}\n\n`));
  } catch (err) {
    console.error("❌ OPS stream error:", err);
  }
};

app.locals.clients = [];

app.get("/events/ops", (req, res) => {
  res.setHeader("Content-Type", "text/event-stream");
  res.setHeader("Cache-Control", "no-cache");
  res.setHeader("Connection", "keep-alive");
  res.flushHeaders();
  app.locals.clients.push(res);
  console.log(`📡 OPS client connected (${app.locals.clients.length} total)`);

  req.on("close", () => {
    app.locals.clients = app.locals.clients.filter((c: any) => c !== res);
    console.log(`🔌 OPS client disconnected (${app.locals.clients.length} remaining)`);
  });
});

setInterval(sendOps, 2500);

app.listen(PORT, () => {
  console.log(`📡 OPS Stream SSE server running at http://localhost:${PORT}/events/ops`);
});
