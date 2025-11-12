// Phase 9 Restoration — Real-time Reflection SSE (one row per event)
import express from "express";
import path from "path";
import DatabaseModule from "better-sqlite3";

const router = express.Router();

router.get("/events/reflections", (req, res) => {
  res.writeHead(200, {
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
  });

  res.write(`data: ${JSON.stringify({ status: "connected" })}\n\n`);

  let lastId = 0;
  const dbPath = path.join(process.cwd(), "db", "main.db");
  const Database = DatabaseModule;
  const db = new Database(dbPath);

  const sendLatest = () => {
    const latest = db
      .prepare("SELECT id, content, created_at FROM reflection_index ORDER BY id DESC LIMIT 1")
      .get();
    if (latest && latest.id !== lastId) {
      lastId = latest.id;
      res.write(`data: ${JSON.stringify(latest)}\n\n`);
    }
  };

  const interval = setInterval(sendLatest, 1000);
  req.on("close", () => clearInterval(interval));
});

export default router;
