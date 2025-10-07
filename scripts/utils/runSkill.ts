// <0001fbE2> runSkill – unified dynamic skill executor with learning + audit
import fs from "fs";
import path from "path";
import crypto from "crypto";
import cfg from "../config/cade.config";
import { audit } from "./audit";
import { ensureDynamicSkill, isAllowedToLearn } from "./learnSkill";
import { runDynamicSkill } from "./loadDynamicSkill";

export async function runSkill(action: string, params: any = {}) {
  try {
    const aliases: Record<string, string> = {
      "file.create": "write to file",
      "file.write": "write to file",
      "create file": "write to file",
    };
    const normalized = aliases[action] || action;

    // 1️⃣ Known direct skills
    switch (normalized) {
      case "write to file": {
        const filePath = params.path || params.filename || "output.txt";
        const content = params.content || "";
        fs.writeFileSync(path.resolve(filePath), content, "utf8");
        const hash = crypto.createHash("sha256").update(content).digest("hex").slice(0, 8);
        const result = `📝 File "${filePath}" created (hash ${hash})`;
        audit("skill.exec", { action: normalized, params, result });
        return { status: "success", result };
      }
    }

    // 2️⃣ Dynamic learning phase
    if (!isAllowedToLearn(action)) {
      const msg = `🤷 Unknown skill (blocked by policy): ${action}`;
      audit("skill.blocked", { action, params, reason: "not allowed by prefix policy" });
      return { status: "blocked", result: msg };
    }

    // 3️⃣ Auto-generate or execute existing skill
    const skillFile = ensureDynamicSkill(action);

    if (!cfg.autoApprove) {
      const preview = await runDynamicSkill(action, params, { dryRun: true });
      audit("skill.preview", { action, params, preview, file: skillFile });
      return { status: "pending", result: `Preview:\n${preview}\n(approve to execute)` };
    }

    const result = await runDynamicSkill(action, params, { dryRun: false });
    audit("skill.exec.dynamic", { action, params, result, file: skillFile });
    return { status: "success", result: String(result) };
  } catch (err: any) {
    audit("skill.error", { action, params, error: err?.message || String(err) });
    return { status: "error", result: `❌ ${err?.message || String(err)}` };
  }
}
