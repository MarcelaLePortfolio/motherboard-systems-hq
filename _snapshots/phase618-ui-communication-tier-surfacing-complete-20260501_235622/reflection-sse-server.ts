// Phase 9 Fix — Reflection SSE server: emit latest reflection one at a time
import express from "express";
import cors from "cors";
import DatabaseModule from "better-sqlite3";
import path from "path";

const app = express();
app.use(cors());

app.get("/events/reflections", (req, res) => {
  res.writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
  });

  res.write(`data: ${JSON.stringify({ status: "connected" })}\n\n`);
  res.flush?.();

  const dbPath = path.join(process.cwd(), "db", "main.db");
  const Database = DatabaseModule;
  const db = new Database(dbPath);
  let lastId = 0;

  const sendLatest = () => {
    try {
      const latest = db
        .prepare("SELECT id, content, created_at FROM reflection_index ORDER BY id DESC LIMIT 1")
        .get();
      if (latest && latest.id !== lastId) {
        lastId = latest.id;
        res.write(`data: ${JSON.stringify(latest)}\n\n`);
        res.flush?.();
      }
    } catch (err) {
      console.error("Reflection SSE error:", err);
    }
  };

  const interval = setInterval(sendLatest, 1000);
  req.on("close", () => clearInterval(interval));
});

app.listen(3101, () => {
  console.log("📡 Reflection SSE server listening on :3101");
});
