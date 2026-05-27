import fs from "fs";
import path from "path";

const dirs = ["tmp", "logs", "cache", "agents"];
for (const dir of dirs) {
  const full = path.join(process.cwd(), dir);
  if (!fs.existsSync(full)) {
    fs.mkdirSync(full, { recursive: true });
    console.log(`<0001fa79> Created missing directory: ${full}`);
  }
}
