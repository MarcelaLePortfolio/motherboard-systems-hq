
import fs from "fs";

const files = [

  "public/js/phase530_visible_panels_bridge.js",

  "routes/api/tasks.ts",

  "routes/tasks.ts",

  "PHASE571_RETRY_DIFFERENTLY_BUTTON_VERIFIED.txt",

  "PHASE582_RETRY_ACTIONS_WIRED_STABLE.txt",

  "PHASE583_WORKER_RETRY_VISIBILITY_ACTIVE.txt",

  "PHASE583_ENFORCE_RETRY_CONTRACT_INTEGRATION.txt",

  "PHASE674_RETRY_CONTRACT_DISCOVERY.md"

];

console.log("===== PHASE 717 EXACT FILE INSPECTION =====");

for (const file of files) {

  if (!fs.existsSync(file)) continue;

  const text = fs.readFileSync(file, "utf8");

  const lines = text.split(/\r?\n/).slice(0, 120);

  console.log(`\n----- ${file} -----`);

  console.log(lines.join("\n"));

}

console.log("\n===== PHASE 717 EXACT FILE INSPECTION COMPLETE =====");

