
import { execSync } from "child_process";

// STEP 1: ONLY ensure client exists where missing

execSync(`

rg "better-sqlite3" -l | while read f; do

  grep -q "import Database" "$f" || sed -i '' '1s/^/import Database from "better-sqlite3";\\n/' "$f"

done

`, { stdio: "inherit" });

// STEP 2: restore ONLY sqlite import where missing (no db mutation)

execSync(`

rg "new Database\\(" db routes scripts -l | while read f; do

  grep -q "sqlite" "$f" || sed -i '' '1s/^/import sqlite from "..\\/db\\/client.js";\\n/' "$f"

done

`, { stdio: "inherit" });

console.log("DB reconciliation pass complete");

