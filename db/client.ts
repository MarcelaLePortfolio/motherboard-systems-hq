import Database from "better-sqlite3";
import path from "path";

const dbPath = path.resolve(process.cwd(), "motherboard.sqlite");
export const db = new Database(dbPath);
console.log("🧩 Using SQLite database at:", dbPath);

// ✅ Create table if not exists
db.exec(`
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
);
`);

// ✅ Export helper
export async function logTaskEvent(entry: {
  type: string;
  status: string;
  actor: string;
  payload: string;
  result: string;
  file_hash: string | null;
}) {
  const id = crypto.randomUUID();
  const stmt = db.prepare(`
    INSERT INTO task_events (id, type, status, actor, payload, result, file_hash, created_at)
    VALUES (@id, @type, @status, @actor, @payload, @result, @file_hash, datetime('now'))
  `);
  stmt.run({ id, ...entry });
  console.log("<0001fab5> 🧩 Logged task_event:", id);
}
