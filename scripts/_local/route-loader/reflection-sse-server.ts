// <0001fae6> Phase 4.8 — Unconditional Inline CORS for SSE Streams
import express from "express";
import chokidar from "chokidar";
import Database from "better-sqlite3";
import path from "path";

const app = express();
const dbPath = path.join(process.cwd(), "db", "main.db");
const clients: any[] = [];

// ✅ Apply CORS to *all* routes, including SSE streams
app.use((req, res, next) => {
  res.setHeader("Access-Control-Allow-Origin", "http://localhost:3001");
  res.setHeader("Access-Control-Allow-Methods", "GET, OPTIONS");
  res.setHeader("Access-Control-Allow-Headers", "Content-Type");
  if (req.method === "OPTIONS") {
    res.writeHead(204);
    res.end();
    return;
  }
  next();
});

app.get("/", (_req, res) => res.send("✅ SSE server with unconditional CORS active."));

app.get("/events/reflections", (req, res) => {
  res.set({
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
  });
  res.flushHeaders();

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
  console.log("🟢 Unconditional CORS SSE server live at http://localhost:3101/events/reflections");
});
