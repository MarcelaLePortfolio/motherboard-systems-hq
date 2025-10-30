// <0001fad8> Phase 4.7-lite — Minimal Reflection SSE Stream (safe add-on)
import { Request, Response } from "express";
import path from "path";
import Database from "better-sqlite3";

const dbPath = path.join(process.cwd(), "db", "main.db");
const clients: Response[] = [];

export function reflectionsSSE(req: Request, res: Response) {
  res.set({
    "Content-Type": "text/event-stream",
    "Cache-Control": "no-cache",
    Connection: "keep-alive",
  });
  res.flushHeaders();
  clients.push(res);
  console.log(`🟢 Reflections SSE client connected (${clients.length})`);
  req.on("close", () => {
    clients.splice(clients.indexOf(res), 1);
    console.log(`🔴 Reflections SSE client disconnected (${clients.length})`);
  });
}

export function broadcastReflections() {
  try {
    const db = new Database(dbPath);
    const rows = db
      .prepare("SELECT id, content, created_at FROM reflection_index ORDER BY created_at DESC LIMIT 10")
      .all();
    const payload = JSON.stringify(rows);
    db.close();
    clients.forEach((c) => c.write(`data: ${payload}\n\n`));
  } catch (err) {
    console.error("❌ Reflection SSE broadcast failed:", err);
  }
}
