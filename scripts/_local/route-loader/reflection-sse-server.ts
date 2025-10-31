// <0001fae8> Phase 4.8 — Manual Header Write (Guaranteed CORS Preflush)
import express from "express";
import chokidar from "chokidar";
import Database from "better-sqlite3";
import path from "path";

const app = express();
const dbPath = path.join(process.cwd(), "db", "main.db");
const clients: any[] = [];

app.get("/", (_req, res) => res.send("✅ Manual-header CORS SSE server active."));

app.get("/events/reflections", (req, res) => {
  // ✅ Write headers manually BEFORE Express auto-sends anything
  res.writeHead(200, {
    "Access-Control-Allow-Origin": "http://localhost:3001",
    "Access-Control-Allow-Methods": "GET, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Content-Type": "text/event-stream; charset=utf-8",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
  });

  clients.push(res);
  console.log(`🟢 SSE client connected (${clients.length})`);

  req.on("close", () => {
    clients.splice(clients.indexOf(res), 1);
    console.log(`🔴 SSE client disconnected (${clients.length})`);
  });
});

function broadcast() {
  try {
    const db = new Database(dbPath);
    const rows = db.prepare("SELECT id, content, created_at FROM reflection_index ORDER BY created_at DESC LIMIT 10").all();
    db.close();
    const payload = JSON.stringify(rows);
    clients.forEach((c) => c.write(`data: ${payload}\n\n`));
    console.log(`📡 Broadcasted ${rows.length} reflections → ${clients.length} clients`);
  } catch (err) {
    console.error("❌ Broadcast failed:", err);
  }
}

const watcher = chokidar.watch([dbPath, dbPath + "-wal", dbPath + "-shm"], { ignoreInitial: true });
watcher.on("change", () => {
  console.log("👁️  Detected DB change → broadcasting...");
  broadcast();
});

app.listen(3101, () => {
  console.log("�� Manual-header CORS SSE server running on http://localhost:3101/events/reflections");
});
