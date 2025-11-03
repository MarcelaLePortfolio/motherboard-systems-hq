import "./ops-sse-bootstrap";
import express from "express";
import path from "path";
import fs from "fs";
const dbPath = path.join(process.cwd(), "db", "main.db");
console.log(`🧩 Using SQLite database at: ${dbPath}`);
import cors from "cors";
import Database from "better-sqlite3"; const sqlite = new Database(dbPath);

const app = express();
app.use(cors());

app.get("/events/ops", (req, res) => {
  res.writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
  });

  const sendOps = () => {
    try {
      const reflections = sqlite
        .prepare("SELECT id, content, created_at FROM reflection_index ORDER BY created_at DESC LIMIT 5")
        .all();
      const tasks = sqlite
        .prepare("SELECT id, type, status, created_at FROM task_events ORDER BY created_at DESC LIMIT 5")
        .all();
      const payload = { reflections, tasks, ts: new Date().toISOString() };
      res.write(`data: ${JSON.stringify(payload)}\n\n`);
    } catch (err) {
      console.error("❌ OPS stream error:", err);
    }
  };

  sendOps();
  const interval = setInterval(sendOps, 5000);
  req.on("close", () => clearInterval(interval));
});

const PORT = process.env.PORT || 3201;
app.listen(PORT, () => {
  console.log(`📡 OPS Stream SSE server running at http://localhost:${PORT}/events/ops`);
});
