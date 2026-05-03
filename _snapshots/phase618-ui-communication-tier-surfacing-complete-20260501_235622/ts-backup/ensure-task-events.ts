// <0001fad3> Phase 5.0 — Ensure SQLite schema for OPS stream
import { sqlite } from "../../db/client";

try {
  sqlite
    .prepare(`CREATE TABLE IF NOT EXISTS task_events (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      description TEXT,
      status TEXT DEFAULT 'pending',
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )`)
    .run();
  console.log("✅ task_events table verified/created successfully.");
} catch (err) {
  console.error("❌ Failed to verify or create task_events:", err);
}
