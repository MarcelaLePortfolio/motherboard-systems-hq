
import { execSync } from "child_process";

console.log("EXECUTION AUTHORITY GRAPH MAP");

const raw = execSync(`rg "execution_authorized" -n .`, { encoding: "utf8" });

const lines = raw.split("\n").filter(Boolean);

const map: Record<string, number> = {};

for (const line of lines) {

  const file = line.split(":")[0];

  map[file] = (map[file] || 0) + 1;

}

const ranked = Object.entries(map)

  .sort((a, b) => b[1] - a[1])

  .slice(0, 10);

console.log(ranked);

