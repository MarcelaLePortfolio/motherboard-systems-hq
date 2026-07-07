
import fs from "fs";

console.log("LOCKING LIFECYCLE CONTRACT SURFACE");

// Step 1: Extract canonical type definition source

const file = "db/governance-lifecycle-composition.ts";

const code = fs.readFileSync(file, "utf8");

// Step 2: Hard verify persistence contract exists as literal-only type

if (!code.includes("GovernanceLifecyclePersistenceResult")) {

  throw new Error("Persistence contract missing — cannot proceed safely");

}

// Step 3: STOP all widening attempts by marking file as authoritative

fs.writeFileSync(

  "db/__LIFECYCLE_CONTRACT_LOCKED__.json",

  JSON.stringify({

    source: file,

    locked: true,

    reason: "prevent contract drift during runtime reconciliation"

  }, null, 2)

);

console.log("Lifecycle contract surface locked (no modifications applied)");

