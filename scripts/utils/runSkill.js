import path from "path";
import fs from "fs";

export async function runSkill(plan, ctx = {}) {
  try {
    const skillsDir = path.join(process.cwd(), "scripts", "skills");
    const file = path.join(skillsDir, `${plan.action}.js`);

    if (fs.existsSync(file)) {
      const { default: skill } = await import(`file://${file}`);
      const result = await skill(plan, ctx);
      return { executed: true, actor: ctx.actor || "cade", ...result };
    }

    return {
      executed: false,
      actor: ctx.actor || "cade",
      summary: `No matching skill for action: ${plan.action}`,
      timestamp: new Date().toISOString()
    };
  } catch (err) {
    return { executed: false, error: err.message };
  }
}
