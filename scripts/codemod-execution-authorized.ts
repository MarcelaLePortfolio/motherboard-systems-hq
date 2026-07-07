
import { execSync } from "child_process";

import fs from "fs";

import path from "path";

function run(cmd: string) {

  return execSync(cmd, { encoding: "utf8" });

}

const files = run(

  `rg "execution_authorized\\s*:" server/operational -l`

)

  .split("\n")

  .filter(Boolean);

function shouldSkip(file: string) {

  return (

    file.includes(".test.ts") ||

    file.includes("boundary") ||

    file.includes("contract")

  );

}

let changedFiles: string[] = [];

for (const file of files) {

  if (shouldSkip(file)) continue;

  const fullPath = path.resolve(file);

  let content = fs.readFileSync(fullPath, "utf8");

  const original = content;

  content = content.replace(

    /execution_authorized\s*:\s*false/g,

    "execution_authorized: authority.execution_authorized"

  );

  if (content !== original) {

    fs.writeFileSync(fullPath, content, "utf8");

    changedFiles.push(file);

  }

}

console.log("CODMOD COMPLETE");

console.log("FILES UPDATED:", changedFiles);

