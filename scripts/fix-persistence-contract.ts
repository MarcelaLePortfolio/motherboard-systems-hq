
import fs from "fs";

const file = "db/governance-lifecycle-persistence.ts";

let code = fs.readFileSync(file, "utf8");

// STEP 1: re-anchor correct return type import

if (!code.includes("GovernanceLifecyclePersistenceResult")) {

  code =

`import type { GovernanceLifecyclePersistenceResult } from "./governance-lifecycle-composition";

` + code;

}

// STEP 2: FORCE return type annotation on function

code = code.replace(

  /export function persistGovernanceEnvelopeLifecycleTransition\((.*?)\)\s*{/s,

  (match, args) => {

    return `export function persistGovernanceEnvelopeLifecycleTransition(${args}): GovernanceLifecyclePersistenceResult {`;

  }

);

fs.writeFileSync(file, code);

console.log("Persistence contract boundary fixed");

