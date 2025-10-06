// 🧠 Cade Self-Reflection Engine – Fixed SQLite Type Binding
import { dbPromise } from "../../db/client";
import { task_events } from "../../db/audit";
import crypto from "crypto";

function safeUUID(): string {
  try {
    const id = crypto.randomUUID?.();
    if (id && typeof id === "string") return id;
  } catch {}
  return "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, c => {
    const r = Math.random() * 16 | 0;
    const v = c === "x" ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
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
    id: String(safeUUID()),
    created_at: new Date().toISOString(),
    summary: JSON.stringify(summary)
  };

  console.log("🧩 Prepared Reflection:", reflection);

  try {
    db.prepare("INSERT INTO reflections (id, created_at, summary) VALUES (?, ?, ?)")
      .run(reflection.id, reflection.created_at, reflection.summary);
    console.log("🧠 Cade reflected:", summary);
  } catch (err) {
    console.error("❌ Reflection insert failed:", err);
  }

  return summary;
}

if (require.main === module) reflect();
