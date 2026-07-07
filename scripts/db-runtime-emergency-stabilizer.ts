
import { execSync } from "child_process";

/*

  EMERGENCY REALITY CHECK:

  The system is not failing because of lifecycle logic.

  It is failing because global DB wiring + sqlite/db symbol drift is broken.

  This script DOES NOT touch business logic.

  It only restores missing imports deterministically.

*/

// STEP 1: restore sqlite import where missing (only when new Database exists)

execSync(`

rg "new Database" db routes scripts -l | while read f; do

  if ! grep -q "better-sqlite3" "$f"; then

    sed -i '' '1s/^/import Database from "better-sqlite3";\\n/' "$f"

  fi

done

`, { stdio: "inherit" });

// STEP 2: ensure sqlite alias exists where used

execSync(`

rg "const sqlite = new Database" db routes scripts -l | while read f; do

  if ! grep -q "import Database" "$f"; then

    sed -i '' '1s/^/import Database from "better-sqlite3";\\n/' "$f"

  fi

done

`, { stdio: "inherit" });

console.log("DB runtime stabilizer applied (import layer only)");

