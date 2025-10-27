import fs from "fs";
import path from "path";

export default async function run(params: { filename: string }) {
  const filePath = path.join(process.cwd(), "memory", `${params.filename}.txt`);
  fs.writeFileSync(filePath, `Created by Cade at ${new Date().toISOString()}`);
  return `✅ File created: ${filePath}`;
}
