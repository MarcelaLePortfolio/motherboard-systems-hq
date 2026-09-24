import crypto from "node:crypto";

import {
  consumeProductionValidationEntryPoint,
} from "../server/validation/production-validation-consumer";

const delegation_id = "8782c8fa-7c82-4ca8-b7cb-3fce7d072b0c";
const package_id = "pkg-68dfc4bc-791d-4156-b32a-e51e458b3160";
const package_version = 1;

const validation_result_id = crypto.randomUUID();

const result = consumeProductionValidationEntryPoint({
  validation_result_id,
  package_id,
  package_version,
  delegation_id,
  validation_status: "VALIDATION_PASSED",
  governance_findings:
    "Exact authorized Delegation verified; no governance blocker identified for bounded Envelope eligibility validation.",
  operational_requirements:
    "Preserve exact governed lineage; require explicit operator Envelope Gate and explicit operator Envelope creation; no automatic progression.",
  capability_requirements:
    "Governed Envelope creation eligibility validation only.",
  escalations: null,
  validation_timestamp: new Date().toISOString(),
});

console.log(JSON.stringify(result, null, 2));

if (!result.ok) {
  process.exit(21);
}

console.log(`LIVE_VALIDATION_RESULT_ID=${validation_result_id}`);
