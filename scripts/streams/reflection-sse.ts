// <0001fad6> Phase 4.7 — Reflection SSE Stream (push-based dashboard updates)
import { Request, Response } from "express";
import fs from "fs";
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
  console.log(`<0001f7e2> Client connected to reflections SSE (${clients.length} total)`);

  req.on("close", () => {
    const index = clients.indexOf(res);
    if (index !== -1) clients.splice(index, 1);
    console.log(`🔴 Client disconnected from reflections SSE (${clients.length} remaining)`);
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

    clients.forEach((client) => client.write(`data: ${payload}\n\n`));
    console.log(`📡 Broadcasted ${rows.length} reflections → ${clients.length} clients`);
  } catch (err) {
    console.error("❌ Reflection SSE broadcast failed:", err);
  }
}

if (require.main === module) {
  const chokidar = (await import("chokidar")).default;
  console.log("👁️  Reflection SSE standalone mode: watching DB for live broadcast...");
  const watcher = chokidar.watch([dbPath, dbPath + "-wal", dbPath + "-shm"], {
    persistent: true,
    ignoreInitial: true,
  });
  watcher.on("change", () => broadcastReflections());
}
