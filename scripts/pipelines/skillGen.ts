import fs from "fs";
import path from "path";
import { planSkillFromPrompt } from "../utils/ollamaPlan";

const skillsDir = path.join(process.cwd(), "scripts", "skills", "dynamic");
const auditFile = path.resolve("db/audit.jsonl");

function logEvent(event: string, payload: any = {}, status: "ok" | "error" = "ok", result?: any) {
  const line = JSON.stringify({
    ts: new Date().toISOString(),
    event,
    status,
    payload,
    result
  });
  fs.mkdirSync(path.dirname(auditFile), { recursive: true });
  fs.appendFileSync(auditFile, line + "\n", "utf8");
}

function sanitizeName(name: string) {
  if (!/^[a-zA-Z0-9._-]+$/.test(name)) throw new Error("Unsafe skill name.");
  return name;
}

export async function generateSkillFromPrompt(prompt: string, explicitName?: string) {
  const { name: plannedName, code } = await planSkillFromPrompt(prompt);
  const name = sanitizeName((explicitName || plannedName).replace(/\.ts$/, ""));
  const fullDir = skillsDir;
  const fullPath = path.join(fullDir, `${name}.ts`);

  fs.mkdirSync(fullDir, { recursive: true });
  fs.writeFileSync(fullPath, code, "utf8");

  logEvent("skill.codegen", { name, prompt }, "ok", { path: fullPath });
  return { name, path: fullPath };
}

export function createSkillDirect(nameRaw: string, code: string) {
  const name = sanitizeName(nameRaw.replace(/\.ts$/, ""));
  const fullDir = skillsDir;
  const fullPath = path.join(fullDir, `${name}.ts`);
  fs.mkdirSync(fullDir, { recursive: true });
  fs.writeFileSync(fullPath, code, "utf8");
  logEvent("skill.codegen", { name, mode: "direct" }, "ok", { path: fullPath });
  return { name, path: fullPath };
}
