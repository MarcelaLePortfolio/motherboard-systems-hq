import Database from "better-sqlite3";

import { execSync } from "child_process";

// 1. ONLY fix missing sqlite imports (DO NOT touch db.* anymore)

execSync(`

rg "new Database\\(" db routes scripts -l | while read f; do

  grep -q "sqlite" "$f" || sed -i '' '1s/^/import sqlite from "..\\/db\\/client.js";\\n/' "$f"

done

`, { stdio: "inherit" });

// 2. Restore broken client imports

execSync(`

rg "from \\"\\.\\.\\/db\\/client" -l | while read f; do

  sed -i '' 's/from "\\.\\.\\/db\\/client.*/from "..\\/db\\/client.js"/g' "$f"

done

`, { stdio: "inherit" });

console.log("DB stabilization pass complete (safe mode)");

