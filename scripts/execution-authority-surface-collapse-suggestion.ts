
import { execSync } from "child_process";

console.log("EXECUTION AUTHORITY SURFACE COLLAPSE SUGGESTION");

function run(cmd: string) {

  try {

    return execSync(cmd, { encoding: "utf8" });

  } catch {

    return "";

  }

}

const raw = run(`rg "execution_authorized" -n .`);

const split = (s: string) => s.split("\n").filter(Boolean);

const map: Record<string, number> = {};

for (const line of split(raw)) {

  const file = line.split(":")[0];

  map[file] = (map[file] || 0) + 1;

}

const ranked = Object.entries(map)

  .sort((a, b) => b[1] - a[1])

  .slice(0, 10);

const top3 = ranked.slice(0, 3).map(([file]) => file);

console.log({

  top_risk_files: ranked,

  suggested_collapse_targets: top3,

  recommendation:

    "Consolidate execution_authorized writes into a single authority boundary module and convert all other occurrences to derived state."

});

