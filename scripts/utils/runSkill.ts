// <0001fbD4> runSkill – unified dynamic skill executor with alias mapping
import fs from "fs";
import path from "path";
import crypto from "crypto";

export async function runSkill(action: string, params: any = {}) {
  try {
    const aliases: Record<string, string> = {
      "file.create": "write to file",
      "file.write": "write to file",
      "create file": "write to file",
    };
    const normalized = aliases[action] || action;
    let result = "";

    switch (normalized) {
      case "write to file": {
        const filePath = params.path || params.filename || "output.txt";
        const content = params.content || "";
        fs.writeFileSync(path.resolve(filePath), content, "utf8");
        const hash = crypto
          .createHash("sha256")
          .update(content)
          .digest("hex")
          .slice(0, 8);
        result = `📝 File "${filePath}" created (hash ${hash})`;
        break;
      }

      default:
        result = `🤷 Unknown skill: ${action}`;
    }

    return { status: "success", result };
  } catch (err: any) {
    return { status: "error", result: `❌ ${err.message || String(err)}` };
  }
}
