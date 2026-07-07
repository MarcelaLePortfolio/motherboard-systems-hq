
import { execSync } from "child_process";

// 1. Normalize DB import usage across repo

execSync(`


  sed -i '' 's/import .* from .*db\\/client.*/import sqlite from "..\\/db\\/client.js"/g' "$f"

done

`, { stdio: "inherit" });

// 2. Remove accidental "sqlite." usage remnants in runtime files

execSync(`

rg "db\\." -l | while read f; do

  sed -i '' 's/db\\./sqlite./g' "$f"

done

`, { stdio: "inherit" });

console.log("DB contract normalization complete");

