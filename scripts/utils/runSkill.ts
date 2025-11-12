import path from "path";

export async function runSkill(skillName: string, params: any): Promise<string> {
  try {
    const skillPath = path.join(process.cwd(), "scripts", "skills", `${skillName}.ts`);
    const skillModule = await import(skillPath);
    const result = await skillModule.default(params);
    return result;
  } catch (err) {
    console.error("❌ runSkill error:", err);
    return `error: ${err.message}`;
  }
}
