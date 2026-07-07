
import { execSync } from "child_process";

console.log("CI EXECUTION AUTHORITY FINAL GATE");

function run(cmd: string) {

  try {

    return execSync(cmd, { encoding: "utf8" });

  } catch {

    return "";

  }

}

const split = (s: string) => s.split("\n").filter(Boolean);

const mutations = split(run(`rg "execution_authorized\\s*[:=]" -n .`));

const dbWrites = split(run(`rg "execution_authorized.*INTEGER|execution_authorized.*number" -n db`));

const assertions = split(run(`rg "assert\\.equal\\(.*execution_authorized" -n .`));

const hasViolation =

  mutations.length > 0 && dbWrites.length > 0;

if (hasViolation) {

  console.error("BLOCKED: execution_authorized multi-owner write surface detected");

  console.error({

    mutations: mutations.length,

    dbWrites: dbWrites.length,

    assertions: assertions.length

  });

  process.exit(1);

}

console.log("PASS: execution_authorized single-owner boundary intact");

