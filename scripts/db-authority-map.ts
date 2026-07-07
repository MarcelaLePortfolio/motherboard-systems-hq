
import { execSync } from "child_process";

console.log("DB AUTHORITY MAP (NO MODIFICATIONS)");

const files = execSync(

  `rg "new Database|db/client|sqlite" -l`,

  { encoding: "utf8" }

).trim().split("\n");

const report = {

  total_files: files.length,

  files,

  recommendation: "collapse all DB access into db/client.ts ONLY"

};

console.log(JSON.stringify(report, null, 2));

