import fs from "fs";
import path from "path";

export default async function run(params: { filename?: string } = {}): Promise<string> {
  const filename = params.filename || "default.txt";
  const targetPath = path.join(process.cwd(), "memory", filename);

  // ensure directory exists
  fs.mkdirSync(path.dirname(targetPath), { recursive: true });
  fs.writeFileSync(targetPath, `File created successfully at ${new Date().toISOString()}`);

  console.log(`<0001fab5> <0001f9e9> File written to ${targetPath}`);
  return `File created at ${targetPath}`;
}
