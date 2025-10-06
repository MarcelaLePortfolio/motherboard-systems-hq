import fs from "fs";
import path from "path";
import { db } from "../../db/client";
import { skills } from "../../db/skills";
import { task_events } from "../../db/audit";
import { eq } from "drizzle-orm";
import { v4 as uuidv4 } from "uuid";

/**
 * runSkill.ts
 * --------------------------------------------------
 * Executes a local system skill.
 * 1️⃣ Checks DB for learned skill first.
 * 2️⃣ Falls back to built-in handlers if none found.
 * 3️⃣ Logs all executions to task_events.
 * --------------------------------------------------
 */
export async function runSkill(action: string, payload: any) {
  let result = "";
  const id = uuidv4();
  const created_at = new Date().toISOString();

  try {
    // 1️⃣ Check for learned skill
    const found = await db.select().from(skills).where(eq(skills.name, action));
    if (found.length > 0) {
      const skill = found[0];
      console.log(`�� Using learned skill: ${skill.name}`);
      const fn = new Function("payload", skill.code);
      result = await fn(payload);
    } else {
      // 2️⃣ Built-in skill fallback
      switch (action) {
        case "mkdir": {
          fs.mkdirSync(path.resolve(payload.path), { recursive: true });
          result = `📁 Created directory: ${payload.path}`;
          break;
        }
        case "writeFile": {
          fs.writeFileSync(path.resolve(payload.path), payload.content, "utf8");
          result = `📝 Wrote file: ${payload.path}`;
          break;
        }
        default:
          result = `🤷 Unknown skill "${action}" — no match in DB`;
      }
    }

    // 3️⃣ Log execution
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

    console.log(`🕒 ${new Date().toLocaleTimeString()} ✅ ${action} completed successfully.`);
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

    console.error(`🕒 ${new Date().toLocaleTimeString()} ❌ ${action} failed:`, error);
    return { status: "error", result: error };
  }
}
