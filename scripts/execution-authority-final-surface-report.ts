
import { execSync } from "child_process";

console.log("EXECUTION AUTHORITY FINAL SURFACE REPORT");

function run(cmd: string) {

  try {

    return execSync(cmd, { encoding: "utf8" });

  } catch {

    return "";

  }

}

const all = run(`rg "execution_authorized" -n .`);

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

const allMap = fileMap(split(all));

const mutMap = fileMap(split(mutations));

const assertMap = fileMap(split(assertions));

const dbMap = fileMap(split(db));

const union = new Set([

  ...Object.keys(allMap),

  ...Object.keys(mutMap),

  ...Object.keys(assertMap),

  ...Object.keys(dbMap)

]);

const report = Array.from(union).map((f) => ({

  file: f,

  refs: allMap[f] || 0,

  mutations: mutMap[f] || 0,

  assertions: assertMap[f] || 0,

  db_surface: dbMap[f] || 0,

  risk_score:

    (mutMap[f] || 0) +

    (dbMap[f] || 0) * 2 +

    (assertMap[f] || 0) * 0.5

}));

const ranked = report

  .sort((a, b) => b.risk_score - a.risk_score)

  .slice(0, 25);

console.log({

  total_files: union.size,

  top_risk_surface: ranked

});

