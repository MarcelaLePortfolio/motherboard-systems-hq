
import { execSync } from "child_process";

console.log("EXECUTION AUTHORITY COLLAPSE ENFORCER");

function run(cmd: string) {

  try {

    return execSync(cmd, { encoding: "utf8" });

  } catch {

    return "";

  }

}

const raw = run(`rg "execution_authorized\\s*[:=]" -n .`);

const lines = raw.split("\n").filter(Boolean);

const assignments: Record<string, string[]> = {};

for (const line of lines) {

  const file = line.split(":")[0];

  assignments[file] = assignments[file] || [];

  assignments[file].push(line);

}

const violations: Record<string, number> = {};

for (const file of Object.keys(assignments)) {

  if (assignments[file].length > 1) {

    violations[file] = assignments[file].length;

  }

}

const sorted = Object.entries(violations)

  .sort((a, b) => b[1] - a[1])

  .slice(0, 20);

console.log({

  rule: "single-write-path-enforcement",

  violation_files: sorted,

  enforcement:

    "Any file with >1 execution_authorized assignment is a structural authority violation candidate."

});

