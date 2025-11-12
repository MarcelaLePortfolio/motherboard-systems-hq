// <0001fad4> Phase 5.0 — Force-create task_events in db/main.db
import Database from "better-sqlite3";
import path from "path";

const dbPath = path.join(process.cwd(), "db", "main.db");
const db = new Database(dbPath);
console.log("🧩 Directly accessing:", dbPath);

try {
  db.prepare(`CREATE TABLE IF NOT EXISTS task_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    description TEXT,
    status TEXT DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`).run();
  console.log("✅ task_events table verified inside main.db");
} catch (err) {
  console.error("❌ Failed to verify or create task_events:", err);
} finally {
  db.close();
}
