// <0001fae3> Phase 4.8 — Global CORS enabled Unified Reflection SSE Server
import express, { Request, Response } from "express";
import path from "path";
import Database from "better-sqlite3";
import chokidar from "chokidar";
import cors from "cors";

const app = express();
app.use(cors({ origin: "http://localhost:3001", methods: ["GET", "OPTIONS"] }));

const dbPath = path.join(process.cwd(), "db", "main.db");
const clients: Response[] = [];

app.get("/events/reflections", (req: Request, res: Response) => {
  res.set({
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
  });
  res.flushHeaders();
  clients.push(res);
  console.log(`<0001f7e2> SSE client connected (${clients.length})`);
  req.on("close", () => {
    const index = clients.indexOf(res);
    if (index !== -1) clients.splice(index, 1);
    console.log(`🔴 SSE client disconnected (${clients.length} remaining)`);
  });
});

function broadcastReflections() {
  try {
    const db = new Database(dbPath);
    const rows = db
      .prepare("SELECT id, content, created_at FROM reflection_index ORDER BY created_at DESC LIMIT 10")
      .all();
    const payload = JSON.stringify(rows);
    db.close();
    clients.forEach((client) => client.write(`data: ${payload}\n\n`));
    console.log(`📡 Broadcasted ${rows.length} reflections → ${clients.length} clients`);
  } catch (err) {
    console.error("❌ Reflection SSE broadcast failed:", err);
  }
}

app.listen(3101, () => {
  console.log("🟢 Unified Reflection SSE stream active at http://localhost:3101/events/reflections (CORS enabled)");
});

const watcher = chokidar.watch([dbPath, dbPath + "-wal", dbPath + "-shm"], {
  persistent: true,
  ignoreInitial: true,
});
watcher.on("change", () => {
  console.log("👁️  Detected DB change — broadcasting reflections...");
  broadcastReflections();
});
