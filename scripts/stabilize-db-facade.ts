import Database from "better-sqlite3";

import { execSync } from "child_process";

// STEP 1: enforce ONLY ONE import style everywhere

execSync(`

rg "new Database\$begin:math:text$\" db routes scripts \-l \| while read f\; do

  sed \-i \'\' \'s\/new Database\\\\\(\(\.\*\)\\$end:math:text$/const sqlite = new Database(\\1)/g' "$f"

done

`, { stdio: "inherit" });

// STEP 2: remove broken db client imports (we will reintroduce cleanly later)

execSync(`


  sed -i '' '/db\\/client/d' "$f"

done

`, { stdio: "inherit" });

console.log("DB facade stabilization pass complete");

