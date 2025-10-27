import path from "path";

/**
 * Universal Skill Runner for Cade 🧠
 * Dynamically imports a skill module from scripts/skills and executes it.
 */
export default async function runSkill(skillName: string, params: any = {}): Promise<string> {
  try {
    const skillPath = path.join(process.cwd(), "scripts", "skills", `${skillName}.ts`);
    const skillModule = await import(skillPath);
    if (typeof skillModule.default !== "function") {
      throw new Error(`Skill "${skillName}" does not export a default function.`);
    }
    const result = await skillModule.default(params);
    return typeof result === "string" ? result : JSON.stringify(result);
  } catch (err: any) {
    return `❌ Failed to execute skill "${skillName}": ${err.message}`;
  }
}
