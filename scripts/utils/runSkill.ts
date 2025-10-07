import fs from "fs";
import path from "path";

type Ctx = { actor?: string };
type RunFn = (params: any, ctx: Ctx) => Promise<string> | string;

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

export async function runSkill(skillName: string, params: any = {}, ctx: Ctx = {}) {
  const name = sanitizeName(skillName.replace(/\.ts$/, ""));
  const fullPath = path.join(skillsDir, `${name}.ts`);

  if (!fs.existsSync(fullPath)) {
    logEvent("skill.error", { name, reason: "missing" }, "error");
    throw new Error(`Skill not found: ${name}`);
  }

  logEvent("skill.exec.dynamic", { name, params, actor: ctx.actor ?? "matilda" });

  const mod: { default?: RunFn } = await import(fullPath + `?t=${Date.now()}`);
  const fn: RunFn | undefined = mod.default;
  if (typeof fn !== "function") {
    logEvent("skill.error", { name, reason: "no-default-export" }, "error");
    throw new Error(`Skill ${name} has no default export run(params, ctx).`);
  }

  try {
    const result = await fn(params, ctx);
    logEvent("skill.success", { name, params }, "ok", result);
    return { status: "success", result };
  } catch (err: any) {
    logEvent("skill.error", { name, params, error: err?.message ?? String(err) }, "error");
    return { status: "error", error: err?.message ?? String(err) };
  }
}
