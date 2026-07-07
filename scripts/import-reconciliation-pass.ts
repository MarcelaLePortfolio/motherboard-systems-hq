
import { execSync } from "child_process";

console.log("IMPORT RECONCILIATION PASS");

// STEP 1: ensure db/client is used everywhere db is referenced

execSync(`

rg "\\bdb\\b" db routes scripts -l | while read f; do

  if ! grep -q "db/client" "$f"; then

    echo "flagged: $f"

  fi

done

`, { stdio: "inherit" });

console.log("Import audit complete");

