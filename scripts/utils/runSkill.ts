import path from "path";
import fs from "fs";
import { logTaskEvent } from "../../db/client.ts";
import { validateTaskEvent } from "./validateTaskEvent.ts";
const eventId = await logTaskEvent({...});
await validateTaskEvent(eventId, payload, result);

export async function runSkill(skill: string, payload: any = {}): Promise<string> {
  console.log(`<0001fab5> 🧩 runSkill invoked for: ${skill}`);
  const skillPath = path.join(process.cwd(), "scripts", "skills", `${skill}.ts`);

  try {
    if (!fs.existsSync(skillPath)) {
      throw new Error(`Skill not found: ${skill}`);
    }

    const mod = await import(`file://${skillPath}`);
    const result = await mod.default(payload);
    console.log(`<0001fab5> 🧠 Skill result:`, result);

    console.log("<0001fab5> <0001f9e9> Invoking logTaskEvent now...");
import { validateTaskEvent } from "./validateTaskEvent.ts";
const eventId = await logTaskEvent({...});
await validateTaskEvent(eventId, payload, result);
    await logTaskEvent({
import { validateTaskEvent } from "./validateTaskEvent.ts";
const eventId = await logTaskEvent({...});
await validateTaskEvent(eventId, payload, result);
      type: "delegation",
      status: "success",
      actor: "matilda",
      payload: JSON.stringify(payload ?? {}),
      result: typeof result === "string" ? result : JSON.stringify(result ?? {}),
      file_hash: null,
    });
    console.log("<0001fab5> ✅ logTaskEvent completed without error");
import { validateTaskEvent } from "./validateTaskEvent.ts";
const eventId = await logTaskEvent({...});
await validateTaskEvent(eventId, payload, result);

    return result;
  } catch (err: any) {
    console.error("❌ runSkill error:", err);
    await logTaskEvent({
import { validateTaskEvent } from "./validateTaskEvent.ts";
const eventId = await logTaskEvent({...});
await validateTaskEvent(eventId, payload, result);
      type: "delegation",
      status: "error",
      actor: "matilda",
      payload: JSON.stringify(payload ?? {}),
      result: err.message || "Unknown error",
      file_hash: null,
    });
    return `❌ Delegation failed: ${err.message}`;
  }
}
