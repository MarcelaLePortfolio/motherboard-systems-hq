import fs from "fs";
import path from "path";
import crypto from "crypto";
import { ollamaPlan } from "./ollamaPlan.js";
import { logTaskEvent } from "./logTaskEvent.js";

export async function runSkill(skill: string, params: any = {}): Promise<string> {
  const skillsDir = path.join(process.cwd(), "scripts", "skills");
  const skillPath = path.join(skillsDir, `${skill}.ts`);
  let resultMessage = "";
  let status = "success";

  try {
    if (fs.existsSync(skillPath)) {
      const mod = await import(skillPath);
      resultMessage = await mod.default(params, {});
    } else {
      const plan = await ollamaPlan(skill);
      const planFile = path.join(process.cwd(), "memory", `cade_plan_${Date.now()}.json`);
      fs.writeFileSync(planFile, JSON.stringify(plan, null, 2));
      resultMessage = `🧩 Cade generated a reasoning plan → ${path.basename(planFile)}`;
    }
  } catch (err: any) {
    status = "error";
    resultMessage = `❌ runSkill failed: ${err.message}`;
  }

  // ✅ Post-task validation + DB log
  try {
    const payload = { skill, params };
    const file_hash = crypto.createHash("sha256").update(resultMessage).digest("hex");
    logTaskEvent({ type: skill, status, actor: "cade", payload, result: resultMessage, file_hash });
  } catch (e: any) {
    console.error("⚠️ post-task log error:", e.message);
  }

  return resultMessage;
}
