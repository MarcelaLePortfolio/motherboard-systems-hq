
import { execSync } from "child_process";

function run(cmd: string) {

  try {

    return execSync(cmd, { encoding: "utf8" });

  } catch {

    return "";

  }

}

const violations = run(`

rg "execution_authorized\\s*[:=]" server routes scripts

| rg -v "execution-authority-core"

| rg -v "ExecutionAuthorityState"

`);

const lines = violations.split("\n").filter(Boolean);

if (lines.length > 0) {

  console.error("BLOCKED: execution_authorized defined outside authority core contract");

  console.error(lines.slice(0, 20));

  process.exit(1);

}

console.log("PASS: Execution authority contract integrity preserved");

