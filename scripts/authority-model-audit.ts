
import { execSync } from "child_process";

console.log("AUTHORITY MODEL CLASSIFICATION");

function run(query: string) {

  try {

    return execSync(query, { encoding: "utf8" });

  } catch {

    return "";

  }

}

const result = [

  run(`rg "execution_authorized: false" -n`),

  run(`rg "execution_authorized: true" -n`),

  run(`rg "execution_authorized: boolean" -n`),

  run(`rg "execution_authorized: number" -n`),

  run(`rg "execution_authorized: false as const" -n`)

].join("\n");

console.log("\n--- AUTHORIZATION USAGE ---\n");

console.log(result || "NO MATCHES FOUND");

