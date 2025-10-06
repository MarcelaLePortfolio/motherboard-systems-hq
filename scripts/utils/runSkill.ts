import { dbPromise, persistToDisk } from "../../db/client";
import { task_events } from "../../db/audit";
import fs from "fs";
import path from "path";
import { v4 as uuidv4 } from "uuid";

/**
 * runSkill.ts
 * Executes a dynamic local skill and records it in the DB.
 */

export async function runSkill(action: string, payload: any) {
  const db = await dbPromise;
  const id = uuidv4();
  const created_at = new Date().toISOString();

  try {
    let result: any;

    switch (action) {
      case "mkdir": {
        fs.mkdirSync(path.resolve(payload.path), { recursive: true });
        result = `📁 Created directory: ${payload.path}`;
        break;
      }
      case "writeFile": {
        fs.writeFileSync(path.resolve(payload.path), payload.content, "utf8");
        result = `✍️  Wrote file: ${payload.path}`;
        break;
      }
      default: {
        result = `🤷 Unknown skill: ${action}`;
      }
    }

    await db.insert(task_events).values({
      id,
      task_id: null,
      type: action,
      status: "success",
      actor: "CadeDynamic",
      payload: JSON.stringify(payload),
      result: JSON.stringify(result),
      file_hash: "",
      created_at,
    });

    // ✅ Explicitly persist after Drizzle write
    persistToDisk();

    console.log(`✅ ${action} completed successfully.`);
    return { status: "success", result };
  } catch (err: any) {
    const error = err?.message || String(err);

    await db.insert(task_events).values({
      id,
      task_id: null,
      type: action,
      status: "error",
      actor: "CadeDynamic",
      payload: JSON.stringify(payload),
      result: JSON.stringify(error),
      file_hash: "",
      created_at,
    });

    persistToDisk();

    console.error(`❌ ${action} failed:`, error);
    return { status: "error", result: error };
  }
}
