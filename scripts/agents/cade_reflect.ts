// 🧠 Cade Self-Reflection Engine – UUID Verification Patch
import { dbPromise } from "../../db/client";
import { task_events } from "../../db/audit";
import crypto from "crypto";

function safeUUID(): string {
  try {
    const id = crypto.randomUUID?.();
    if (id && typeof id === "string") return id;
  } catch {}
  // Guaranteed manual fallback
  const fallback = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx".replace(/[xy]/g, c => {
    const r = Math.random() * 16 | 0;
    const v = c === "x" ? r : (r & 0x3) | 0x8;
    return v.toString(16);
  });
  return fallback;
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

  console.log("🧩 Generated Reflection ID:", reflection.id);

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
