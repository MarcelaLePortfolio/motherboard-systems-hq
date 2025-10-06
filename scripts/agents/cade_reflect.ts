// 🧠 Cade Self-Reflection Engine – Phase 4
import { dbPromise } from "../../db/client";
import { task_events } from "../../db/audit";
import { v4 as uuidv4 } from "uuid";
import fs from "fs";

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
    id: uuidv4(),
    created_at: new Date().toISOString(),
    summary: JSON.stringify(summary)
  };

  db.run(
    "INSERT INTO reflections (id, created_at, summary) VALUES (?, ?, ?)",
    [reflection.id, reflection.created_at, reflection.summary]
  );

  console.log("🧠 Cade reflected:", summary);
  return summary;
}

if (require.main === module) reflect();
