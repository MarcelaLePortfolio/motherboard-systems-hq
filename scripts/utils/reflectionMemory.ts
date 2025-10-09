import fs from "fs";
import path from "path";

const reflectionDir = path.join(process.cwd(), "memory", "reflections");
fs.mkdirSync(reflectionDir, { recursive: true });

export async function recordReflection(entry: any) {
  const file = path.join(reflectionDir, `reflection_${Date.now()}.json`);
  fs.writeFileSync(file, JSON.stringify(entry, null, 2), "utf8");
  console.log(`🪞 Reflection recorded → ${file}`);
}

export function loadReflections(): any[] {
  const files = fs.readdirSync(reflectionDir).filter(f => f.endsWith(".json"));
  return files.map(f => JSON.parse(fs.readFileSync(path.join(reflectionDir, f), "utf8")));
}
