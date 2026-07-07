
import { execSync } from "child_process";

console.log("EXECUTION AUTHORITY DEEP TRACE");

function run(cmd: string) {

  try {

    return execSync(cmd, { encoding: "utf8" });

  } catch {

    return "";

  }

}

const sources = run(`rg "execution_authorized" -n .`);

const mutations = run(`rg "execution_authorized\\s*[:=]" -n .`);

const assertions = run(`rg "assert\\.equal\\(.*execution_authorized" -n .`);

const split = (s: string) => s.split("\n").filter(Boolean);

const summarize = (lines: string[]) => {

  const map: Record<string, number> = {};

  for (const l of lines) {

    const file = l.split(":")[0];

    map[file] = (map[file] || 0) + 1;

  }

  return Object.entries(map)

    .sort((a, b) => b[1] - a[1])

    .slice(0, 15);

};

console.log({

  total_refs: split(sources).length,

  total_mutations: split(mutations).length,

  total_assertions: split(assertions).length,

  top_mutation_files: summarize(split(mutations)),

  top_assertion_files: summarize(split(assertions))

});

