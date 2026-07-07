
import { execSync } from "child_process";

console.log("EXECUTION AUTHORITY CONSISTENCY CHECK");

function run(cmd: string) {

  try {

    return execSync(cmd, { encoding: "utf8" });

  } catch {

    return "";

  }

}

const all = run(`rg "execution_authorized" -n .`);

const mutations = run(`rg "execution_authorized\\s*[:=]" -n .`);

const booleans = run(`rg "execution_authorized:\\s*(true|false)" -n .`);

const split = (s: string) => s.split("\n").filter(Boolean);

const files = (lines: string[]) => {

  const map: Record<string, number> = {};

  for (const l of lines) {

    const file = l.split(":")[0];

    map[file] = (map[file] || 0) + 1;

  }

  return map;

};

const allMap = files(split(all));

const mutMap = files(split(mutations));

const boolMap = files(split(booleans));

const overlapScore = Object.keys(mutMap).map(f => ({

  file: f,

  refs: allMap[f] || 0,

  mutations: mutMap[f] || 0,

  explicitBooleans: boolMap[f] || 0,

  risk_score: (mutMap[f] || 0) / ((allMap[f] || 1))

})).sort((a, b) => b.risk_score - a.risk_score).slice(0, 20);

console.log({

  total_files: Object.keys(allMap).length,

  mutation_surface: Object.keys(mutMap).length,

  top_risk_files: overlapScore

});

