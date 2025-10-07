import fs from "fs";
import path from "path";
import cfg from "../config/cade.config";
import { audit } from "./audit";

function safeFileName(action: string) {
  return action.replace(/[^a-z0-9._-]/gi, "_");
}

export function isAllowedToLearn(action: string): boolean {
  return cfg.allowedPrefixes.some(p => action.startsWith(p));
}

/** Write a tiny, typed dynamic skill module if it doesn't exist yet */
export function ensureDynamicSkill(action: string) {
  const fname = safeFileName(action) + ".ts";
  const outDir = path.resolve(cfg.sandboxRoot);
  const outFile = path.join(outDir, fname);

  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
  if (fs.existsSync(outFile)) return outFile;

  const tpl = `// Auto-generated dynamic skill for "${action}"
type Params = Record<string, any>;

/**
 * Convention: export default async function(params, ctx)
 * Return a short human string summarizing the result.
 */
export default async function run(params: Params, ctx: { dryRun?: boolean }) {
  if (ctx?.dryRun) {
    return \`(dry-run) would perform: ${action} with \${JSON.stringify(params)}\`;
  }
  // TODO: replace with real logic. Keep file-system/network changes minimal here.
  return \`✅ ${action} completed with \${JSON.stringify(params)}\`;
}
`;

  fs.writeFileSync(outFile, tpl, "utf8");
  audit("skill.generated", { action, file: outFile });
  return outFile;
}
