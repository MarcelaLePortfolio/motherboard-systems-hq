// <0001fad5> Phase 5.0 — OPS SSE bootstrap schema enforcement
import Database from "better-sqlite3";
import path from "path";
const dbPath = path.join(process.cwd(), "db", "main.db");
const db = new Database(dbPath);
console.log("🧩 OPS Bootstrap — Verifying schema at:", dbPath);
try {
    db.prepare(`CREATE TABLE IF NOT EXISTS task_events (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    description TEXT,
    status TEXT DEFAULT 'pending',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  )`).run();
    console.log("✅ task_events table confirmed for OPS SSE runtime");
}
catch (err) {
    console.error("❌ OPS SSE bootstrap failed:", err);
}
finally {
    db.close();
}
