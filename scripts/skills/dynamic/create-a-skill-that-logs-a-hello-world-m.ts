import fs from "fs";
import path from "path";

/**
 * Auto-generated dynamic skill from prompt:
 * create a skill that logs a hello world message
 */
export default async function run(params: any, ctx: { actor?: string }): Promise<string> {
  const out = path.join(process.cwd(), "memory", "skills");
  fs.mkdirSync(out, { recursive: true });
  const marker = path.join(out, "create-a-skill-that-logs-a-hello-world-m.log");
  fs.appendFileSync(marker, `[${new Date().toISOString()}] run by ${ctx.actor ?? "unknown"} with ${JSON.stringify(params)}\n`);
  return "✅ create-a-skill-that-logs-a-hello-world-m executed (scaffold).";
}
