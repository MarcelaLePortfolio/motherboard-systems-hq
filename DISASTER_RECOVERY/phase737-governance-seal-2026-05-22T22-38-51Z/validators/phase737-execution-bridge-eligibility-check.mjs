
import fs from "node:fs";

const requiredFiles = [

  "EXECUTION_BRIDGE_ELIGIBILITY_CONTRACT.md",

  "ARTIFACT_SNAPSHOTS",

  "DISASTER_RECOVERY/phase737-execution-gap-audit-result.md",

  "scripts/reconciliation-snapshot-validator.mjs",

];

const requiredContractTerms = [

  "consume validated artifact snapshot",

  "consume validated structured diff",

  "require Matilda semantic approval",

  "emit execution audit record",

  "rebuild post-execution artifact snapshot",

  "run reconciliation comparison",

  "no execution from conversational language",

  "no execution from Preview",

  "no execution from semantic-preview",

];

const failures = [];

for (const file of requiredFiles) {

  if (!fs.existsSync(file)) {

    failures.push(`Missing required file or directory: ${file}`);

  }

}

if (fs.existsSync("EXECUTION_BRIDGE_ELIGIBILITY_CONTRACT.md")) {

  const contract = fs.readFileSync("EXECUTION_BRIDGE_ELIGIBILITY_CONTRACT.md", "utf8");

  for (const term of requiredContractTerms) {

    if (!contract.includes(term)) {

      failures.push(`Missing required contract term: ${term}`);

    }

  }

}

console.log("== Phase 737 Execution Bridge Eligibility Check ==");

if (failures.length > 0) {

  console.log("FAIL");

  for (const failure of failures) {

    console.log(`- ${failure}`);

  }

  process.exit(1);

}

console.log("PASS");

console.log("Execution bridge eligibility contract exists and preserves mandatory non-authority gates.");

console.log("This validator is read-only and grants no execution authority.");

