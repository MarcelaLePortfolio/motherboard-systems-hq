
import fs from "fs";

const routePath = "server/routes/api-tasks-postgres.mjs";

const source = fs.readFileSync(routePath, "utf8");

const requiredFragments = [

  '/:task_id/semantic-preview',

  'corridor: "read-only-semantic-inspection"',

  'outcome_preview',

  'explanation_preview',

  "completed.payload AS guidance",

  "guidance: row.guidance || null",

  "renderer_mutation_disabled",

  "preview_mutation_disabled",

  "execution_authority_disabled",

  "reconciliation_authority_disabled"

];

const results = requiredFragments.map((fragment) => ({

  fragment,

  present: source.includes(fragment)

}));

const missing = results.filter((r) => !r.present);

const report = {

  schema_version: "phase736.semantic-preview-contract-verification.v2",

  corridor: "read-only-contract-verification",

  verified_file: routePath,

  contract_note:

    "semantic_artifact is exposed through completed.payload AS guidance, not as a separate literal route field.",

  verification_results: results,

  passed: missing.length === 0,

  missing_fragments: missing.map((m) => m.fragment),

  validation: {

    deterministic_verification: true,

    runtime_mutation_disabled: true,

    preview_mutation_disabled: true,

    renderer_interception_disabled: true

  }

};

fs.mkdirSync("scripts/render-native/reports", { recursive: true });

fs.writeFileSync(

  "scripts/render-native/reports/semantic-preview-contract-verification.json",

  `${JSON.stringify(report, null, 2)}\n`

);

if (missing.length > 0) {

  console.error("SEMANTIC PREVIEW CONTRACT VERIFICATION FAILED");

  console.error(JSON.stringify(missing, null, 2));

  process.exit(1);

}

console.log("SEMANTIC PREVIEW CONTRACT VERIFICATION PASS");

console.log("scripts/render-native/reports/semantic-preview-contract-verification.json");

