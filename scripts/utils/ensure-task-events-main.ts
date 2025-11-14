import { sqlite } from "../../db/client";

try {
  sqlite.exec(`
    CREATE TABLE IF NOT EXISTS task_events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT,
      agent TEXT,
      status TEXT,
      payload TEXT,
      result TEXT,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    );
  `);
  console.log("✅ task_events table verified");
} catch (err) {
  console.error("❌ Failed to ensure task_events table:", err);
}
