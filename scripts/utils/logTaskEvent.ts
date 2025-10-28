import Database from "better-sqlite3";
import path from "path";
import * as crypto from "crypto";

export function logTaskEvent({
  type,
  status,
  actor,
  payload,
  result,
  file_hash
}: {
  type: string;
  status: string;
  actor: string;
  payload?: any;
  result?: any;
  file_hash?: string | null;
}) {
  try {
    const dbPath = path.resolve(process.cwd(), "motherboard.sqlite");
    const db = new Database(dbPath);
    db.prepare(`
      CREATE TABLE IF NOT EXISTS task_events (
        id TEXT PRIMARY KEY,
        task_id TEXT,
        type TEXT,
        status TEXT,
        actor TEXT,
        payload TEXT,
        result TEXT,
        file_hash TEXT,
        created_at TEXT
      )
    `).run();

    const id = crypto.randomUUID();
    const created_at = new Date().toISOString();
    db.prepare(`
      INSERT INTO task_events (id, type, status, actor, payload, result, file_hash, created_at)
      VALUES (@id, @type, @status, @actor, @payload, @result, @file_hash, @created_at)
    `).run({
      id,
      type,
      status,
      actor,
      payload: JSON.stringify(payload || {}),
      result: typeof result === "string" ? result : JSON.stringify(result || {}),
      file_hash,
      created_at
    });

    // 🧹 Keep latest 50 entries only
    db.prepare("DELETE FROM task_events WHERE id NOT IN (SELECT id FROM task_events ORDER BY created_at DESC LIMIT 50)").run();
    db.close();
    console.log(`🧾 Logged task_event → ${id}`);
  } catch (err: any) {
    console.error("❌ logTaskEvent error:", err.message);
  }
}
