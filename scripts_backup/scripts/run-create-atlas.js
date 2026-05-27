import fs from "fs";
const agent = process.argv[2] || "Atlas";
const dir = `agents/${agent}`;
if (!fs.existsSync(dir)) {
  fs.mkdirSync(dir, { recursive: true });
  console.log(`<0001fad9> Created ${dir}`);
}
process.exit(0);
