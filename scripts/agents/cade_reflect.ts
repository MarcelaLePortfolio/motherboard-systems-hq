// 🧠 Cade Self-Reflection Engine – Fixed UUID + SQL.js Compatibility
import { dbPromise } from "../../db/client";
import { task_events } from "../../db/audit";
import fs from "fs";
import crypto from "crypto";

function safeUUID() {
  try {
    return crypto.randomUUID();
  } catch {
    return ([1e7]+-1e3+-4e3+-8e3+-1e11).replace(/[018]/g, c =>
      (c ^ crypto.randomBytes(1)[0] & 15 >> c / 4).toString(16)
    );
  }
}

export async function reflect() {
  const db = await dbPromise;
  const events = db.select().from(task_events).all();

  const total = events.length;
  const success = events.filter(e => e.status === "success").length;
  const recent = events.slice(-5).map(e => e.type);

  const summary = {
    total_tasks: total,
    success_rate: total ? success / total : 0,
    recent_actions: recent
  };

  const reflection = {
    id: safeUUID(),
    created_at: new Date().toISOString(),
    summary: JSON.stringify(summary)
  };

  try {
    db.run(
      "INSERT INTO reflections (id, created_at, summary) VALUES (?, ?, ?)",
      [reflection.id, reflection.created_at, reflection.summary]
    );
    console.log("🧠 Cade reflected:", summary);
  } catch (err) {
    console.error("❌ Reflection insert failed:", err);
  }
  return summary;
}

if (require.main === module) reflect();
