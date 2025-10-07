// <0001fbF0> ollamaGenerateSkill – Cade autonomous code generation
import fs from "fs";
import path from "path";
import { execSync } from "child_process";
import cfg from "../config/cade.config";
import { audit } from "./audit";

export async function ollamaGenerateSkill(action: string, params: any = {}) {
  const prompt = `
You are Cade, a senior TypeScript automation engineer.
Write a self-contained TypeScript module that implements this action:

Project context:
This system serves a dashboard HTML file at public/dashboard.html containing a chatbot section followed by an Agent Status section. When actions reference "dashboard" or "agent status", they refer to modifying or rearranging HTML content in this file.



Action: "${action}"
Parameters: ${JSON.stringify(params, null, 2)}

Constraints:
• The module must export default async function run(params, ctx)
• It must stay inside the project sandbox at ${cfg.sandboxRoot}
• Use only Node built-ins (fs, path, crypto, etc.)
• Avoid destructive operations; make reversible edits
• Keep responses short, human-readable, and return a concise string summarizing the change

Output ONLY valid TypeScript code. No commentary.
`;

  try {
    const output = execSync(`ollama run llama3:8b "${prompt}"`, { encoding: "utf8", maxBuffer: 5 * 1024 * 1024 });
    const clean = output.replace(/```ts|```typescript|```/g, "").trim();
    const fileName = action.replace(/[^a-z0-9._-]/gi, "_") + ".ts";
    const outPath = path.resolve(cfg.sandboxRoot, fileName);
    fs.writeFileSync(outPath, clean, "utf8");
    audit("skill.codegen", { action, file: outPath });
    return outPath;
  } catch (err: any) {
    audit("skill.codegen.error", { action, error: err.message || String(err) });
    throw err;
  }
}
