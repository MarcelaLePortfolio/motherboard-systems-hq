
import { execSync } from "child_process";

console.log("CI EXECUTION AUTHORITY GATE");

function run(cmd: string) {

  try {

    return execSync(cmd, { encoding: "utf8" });

  } catch {

    return "";

  }

}

const mutations = run(`rg "execution_authorized\\s*[:=]" -n .`);

const dbWrites = run(`rg "execution_authorized.*INTEGER|execution_authorized.*number" -n db`);

const hasViolations =

  mutations.split("\n").filter(Boolean).length > 0 ||

  dbWrites.split("\n").filter(Boolean).length > 0;

if (hasViolations) {

  console.error("BLOCKED: execution_authorized has multiple write surfaces");

  console.error({

    mutations: mutations.split("\n").filter(Boolean).length,

    dbWrites: dbWrites.split("\n").filter(Boolean).length

  });

  process.exit(1);

}

console.log("PASS: single-source authority maintained");

