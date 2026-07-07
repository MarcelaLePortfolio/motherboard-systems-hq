
import { execSync } from "child_process";

console.log("EXECUTION AUTHORITY UNIFIED CORE");

function run(cmd: string) {

  try {

    return execSync(cmd, { encoding: "utf8" });

  } catch {

    return "";

  }

}

const split = (s: string) => s.split("\n").filter(Boolean);

const countByFile = (lines: string[]) => {

  const map: Record<string, number> = {};

  for (const l of lines) {

    const file = l.split(":")[0];

    map[file] = (map[file] || 0) + 1;

  }

  return map;

};

const sources = split(run(`rg "execution_authorized" -n .`));

const mutations = split(run(`rg "execution_authorized\\s*[:=]" -n .`));

const db = split(run(`rg "execution_authorized.*INTEGER|execution_authorized.*number" -n db`));

const assertions = split(run(`rg "assert\\.equal\\(.*execution_authorized" -n .`));

const srcMap = countByFile(sources);

const mutMap = countByFile(mutations);

const dbMap = countByFile(db);

const assertMap = countByFile(assertions);

const files = new Set([

  ...Object.keys(srcMap),

  ...Object.keys(mutMap),

  ...Object.keys(dbMap),

  ...Object.keys(assertMap),

]);

const perFile = Array.from(files).map((f) => {

  const refs = srcMap[f] || 0;

  const mut = mutMap[f] || 0;

  const dbv = dbMap[f] || 0;

  const asrt = assertMap[f] || 0;

  const origin_score = mut > 0 ? 1 : 0;

  const drift_score = mut + dbv * 2;

  const stability_score = asrt * 0.5;

  return {

    file: f,

    refs,

    mutations: mut,

    db: dbv,

    assertions: asrt,

    origin_score,

    drift_score,

    stability_score,

    total_score: drift_score + stability_score

  };

});

const ranked = perFile.sort((a, b) => b.total_score - a.total_score).slice(0, 20);

const convergence = {

  total_files: files.size,

  total_mutations: mutations.length,

  total_db: db.length,

  top_risk: ranked,

  status:

    mutations.length > 0 && db.length > 0

      ? "MULTI-OWNER AUTHORITY DETECTED"

      : "SINGLE OWNER CONVERGED (OR DEGENERATE STATE)"

};

console.log(JSON.stringify(convergence, null, 2));

