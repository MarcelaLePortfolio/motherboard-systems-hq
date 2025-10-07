import { getDb } from "../../db/client";
import { skills } from "../../db/skills";
import { eq } from "drizzle-orm";
import { v4 as uuidv4 } from "uuid";

/**
 * learnSkill.ts
 * --------------------------------------------------
 * Persists a newly learned skill into the database.
 * Used by CadeDynamic when Ollama proposes a new action.
 * --------------------------------------------------
 */
export async function learnSkill(name: string, description: string, code: string) {
  const db = getDb();
  const existing = await db.select().from(skills).where(eq(skills.name, name));

  if (existing.length > 0) {
    console.log(`🔁 Skill "${name}" already exists.`);
    return existing[0];
  }

  const newSkill = {
    id: uuidv4(),
    name,
    description,
    code,
    created_at: new Date().toISOString(),
  };

  await db.insert(skills).values(newSkill);
  console.log(`🧠 Learned new skill: ${name}`);
  return newSkill;
}
