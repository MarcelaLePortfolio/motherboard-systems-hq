export async function planSkillFromPrompt(prompt: string) {
  const base = prompt
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/(^-|-$)/g, "")
    .slice(0, 40) || "generated-skill";

  const name = base;
  const params = {};

  const code = `import fs from "fs";
import path from "path";

/**
 * Auto-generated dynamic skill from prompt:
 * ${prompt.replace(/\*\//g, "*\\/")}
 */
export default async function run(params: any, ctx: { actor?: string }): Promise<string> {
  const out = path.join(process.cwd(), "memory", "skills");
  fs.mkdirSync(out, { recursive: true });
  const marker = path.join(out, "${name}.log");
  fs.appendFileSync(marker, \`[\${new Date().toISOString()}] run by \${ctx.actor ?? "unknown"} with \${JSON.stringify(params)}\\n\`);
  return "✅ ${name} executed (scaffold).";
}
`;
  return { name, params, code };
}
