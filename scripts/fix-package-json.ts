
import fs from "fs";

const path = "package.json";

const raw = fs.readFileSync(path, "utf8");

// remove accidental JS injection line

const cleaned = raw

  .split("\n")

  .filter(line => !line.trim().startsWith("import Database"))

  .join("\n");

fs.writeFileSync(path, cleaned);

console.log("package.json cleaned");

