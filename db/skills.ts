import fs from "fs";
import path from "path";

const skillsPath = path.resolve("db/skills.json");

export function getSkillFamilies() {
  return JSON.parse(fs.readFileSync(skillsPath, "utf8")).families;
}

export function findClosestSkill(action: string): string | null {
  const families = getSkillFamilies();
  const [prefix] = action.split(".");
  const group = families[prefix] || [];
  if (group.length === 0) return null;

  const best = group.find(a => a.includes(action.split(".")[1]));
  return best || group[0] || null;
}

export function addSkillToFamily(prefix: string, skill: string) {
  const data = JSON.parse(fs.readFileSync(skillsPath, "utf8"));
  if (!data.families[prefix]) data.families[prefix] = [];
  if (!data.families[prefix].includes(skill)) data.families[prefix].push(skill);
  fs.writeFileSync(skillsPath, JSON.stringify(data, null, 2));
}
