
import { execSync } from "child_process";

console.log("EXECUTION AUTHORITY FINAL GATE CHECK");

function run(cmd: string) {

  try {

    return execSync(cmd, { encoding: "utf8" });

  } catch {

    return "";

  }

}

const mutations = run(`rg "execution_authorized\\s*[:=]" -n .`);

const assertions = run(`rg "assert\\.equal\\(.*execution_authorized" -n .`);

const db = run(`rg "execution_authorized.*INTEGER|execution_authorized.*number" -n db`);

const split = (s: string) => s.split("\n").filter(Boolean);

const fileMap = (lines: string[]) => {

  const map: Record<string, number> = {};

  for (const l of lines) {

    const file = l.split(":")[0];

    map[file] = (map[file] || 0) + 1;

  }

  return map;

};

const mutMap = fileMap(split(mutations));

const assertMap = fileMap(split(assertions));

const dbMap = fileMap(split(db));

const allFiles = new Set([

  ...Object.keys(mutMap),

  ...Object.keys(assertMap),

  ...Object.keys(dbMap)

]);

const gateViolations = Array.from(allFiles)

  .map((f) => ({

    file: f,

    mutations: mutMap[f] || 0,

    assertions: assertMap[f] || 0,

    db: dbMap[f] || 0,

    score: (mutMap[f] || 0) * 2 + (dbMap[f] || 0) * 3

  }))

  .sort((a, b) => b.score - a.score);

const top = gateViolations.slice(0, 15);

console.log({

  rule: "execution_authorized_single_source_gate",

  top_violation_candidates: top,

  enforcement:

    "If db or mutation presence > 0 outside gate layer, treat as architectural drift."

});

