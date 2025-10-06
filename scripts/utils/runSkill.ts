import fs from "fs";
import path from "path";

export async function runSkill(plan: any) {
  try {
    switch (plan.action) {
      case "mkdir":
        fs.mkdirSync(path.resolve(plan.path), { recursive: true });
        return { status: "success", message: `Created folder: ${plan.path}` };
      case "writeFile":
        fs.writeFileSync(path.resolve(plan.path), plan.content || "", "utf8");
        return { status: "success", message: `Wrote file: ${plan.path}` };
      default:
        return { status: "error", message: `Unknown action: ${plan.action}` };
    }
  } catch (err: any) {
    return { status: "error", message: `Skill failed: ${err.message}` };
  }
}