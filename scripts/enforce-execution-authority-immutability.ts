
import { execSync } from "child_process";

function run(cmd: string) {

  try {

    return execSync(cmd, { encoding: "utf8" });

  } catch {

    return "";

  }

}

const violations = run(`rg "_authorized\\s*[:=]" server routes scripts | rg -v "execution-authority-core"`);

const lines = violations.split("\n").filter(Boolean);

if (lines.length > 0) {

  console.error("BLOCKED: Unauthorized execution authority mutation detected");

  console.error(lines.slice(0, 20));

  process.exit(1);

}

console.log("PASS: Execution authority immutability preserved");

