import path from "path";
import { pathToFileURL } from "url";
import cfg from "../config/cade.config";

export async function runDynamicSkill(action: string, params: any, opts: { dryRun?: boolean } = {}) {
  const fileName = action.replace(/[^a-z0-9._-]/gi, "_") + ".ts";
  const fullPath = path.resolve(cfg.sandboxRoot, fileName);
  const mod = await import(pathToFileURL(fullPath).href);
  const fn = mod.default;
  if (typeof fn !== "function") throw new Error(`Dynamic skill "${action}" has no default function`);
  return await fn(params, { dryRun: !!opts.dryRun });
}
