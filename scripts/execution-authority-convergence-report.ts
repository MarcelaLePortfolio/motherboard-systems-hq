
import { execSync } from "child_process";

console.log("EXECUTION AUTHORITY CONVERGENCE REPORT");

function run(cmd: string) {

  try {

    return execSync(cmd, { encoding: "utf8" });

  } catch {

    return "";

  }

}

const mutations = run(`rg "execution_authorized\\s*[:=]" -n .`);

const db = run(`rg "execution_authorized.*INTEGER|execution_authorized.*number" -n db`);

const assertions = run(`rg "assert\\.equal\\(.*execution_authorized" -n .`);

const gates = run(`rg "execution-approval-gate|execution_authorized.*true|execution_authorized.*false as const" -n .`);

const split = (s: string) => s.split("\n").filter(Boolean);

const countByFile = (lines: string[]) => {

  const map: Record<string, number> = {};

  for (const l of lines) {

    const file = l.split(":")[0];

    map[file] = (map[file] || 0) + 1;

  }

  return map;

};

const mutMap = countByFile(split(mutations));

const dbMap = countByFile(split(db));

const assertMap = countByFile(split(assertions));

const gateMap = countByFile(split(gates));

const files = new Set([

  ...Object.keys(mutMap),

  ...Object.keys(dbMap),

  ...Object.keys(assertMap),

  ...Object.keys(gateMap),

]);

const ranked = Array.from(files)

  .map((f) => ({

    file: f,

    mutations: mutMap[f] || 0,

    db: dbMap[f] || 0,

    assertions: assertMap[f] || 0,

    gate: gateMap[f] || 0,

    authority_score:

      (mutMap[f] || 0) * 2 +

      (dbMap[f] || 0) * 3 +

      (gateMap[f] || 0) * 1.5

  }))

  .sort((a, b) => b.authority_score - a.authority_score)

  .slice(0, 20);

const total_mutations = Object.values(mutMap).reduce((a, b) => a + b, 0);

const total_db = Object.values(dbMap).reduce((a, b) => a + b, 0);

console.log({

  total_mutations,

  total_db,

  top_authority_conflict_files: ranked,

  conclusion:

    total_db > 0 && total_mutations > 0

      ? "MULTI-OWNER STATE DETECTED: execution_authorized is not centralized"

      : "SINGLE OWNER STATE: convergence achieved"

});

