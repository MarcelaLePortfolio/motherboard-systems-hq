import fs from "fs";
import path from "path";
import { ollamaPlan } from "./ollamaPlan.js";

export async function runSkill(skill: string, params: any = {}): Promise<string> {
  const skillsDir = path.join(process.cwd(), "scripts", "skills");
  const skillPath = path.join(skillsDir, `${skill}.ts`);

  if (fs.existsSync(skillPath)) {
    const mod = await import(skillPath);
    return await mod.default(params, {});
  }

  // 🤖 No direct skill match — let Cade reason with Ollama
  const plan = await ollamaPlan(skill);
  const planFile = path.join(process.cwd(), "memory", `cade_plan_${Date.now()}.json`);
  fs.writeFileSync(planFile, JSON.stringify(plan, null, 2));
  return `🧩 Cade generated a reasoning plan → ${path.basename(planFile)}`;
}
