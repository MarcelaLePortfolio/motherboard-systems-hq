
import fs from "node:fs";

import Database from "better-sqlite3";

const packageId = "smoke-governance-envelope-gate-runtime-package";

const packageVersion = 1;

const delegationId = "smoke-governance-envelope-gate-runtime-delegation";

const validationResultId = "smoke-governance-envelope-gate-runtime-validation";

const envelopeGateId = "smoke-governance-envelope-gate-runtime";

const dbPath = "db/main.db";

const migrationPath = "drizzle/0004_governance_lifecycle_artifacts.sql";

const db = new Database(dbPath);

db.pragma("foreign_keys = ON");

db.exec(fs.readFileSync(migrationPath, "utf8"));

const {

  createGovernancePackage,

  createGovernanceDelegation,

  createGovernanceValidationResult,

  createGovernanceEnvelopeGate,

} = await import("../db/governance-runtime.ts");

function cleanup() {

  db.prepare("DELETE FROM governance_envelope_gates WHERE envelope_gate_id = ?").run(envelopeGateId);

  db.prepare("DELETE FROM governance_envelope_gates WHERE envelope_gate_id = ?").run("smoke-governance-envelope-gate-runtime-missing-field");

  db.prepare("DELETE FROM governance_envelope_gates WHERE envelope_gate_id = ?").run("smoke-governance-envelope-gate-runtime-missing-validation");

  db.prepare("DELETE FROM governance_validation_results WHERE validation_result_id = ?").run(validationResultId);

  db.prepare("DELETE FROM governance_delegations WHERE delegation_id = ?").run(delegationId);

  db.prepare("DELETE FROM governance_packages WHERE package_id = ? AND package_version = ?").run(packageId, packageVersion);

}

function assert(condition, message) {

  if (!condition) {

    throw new Error(message);

  }

}

try {

  cleanup();

  createGovernancePackage({

    package_id: packageId,

    package_version: packageVersion,

    project_id: "hq",

    conversation_id: "conversation-governance-bridge",

    requested_outcome: "Provide Package lineage for governance Envelope Gate runtime smoke validation",

    scope: "Envelope Gate runtime smoke test only",

    containment: "No envelope creation, routing, assignment, execution, automation, or agent invocation",

    constraints: "Reversible test data only",

    success_criteria: "Envelope Gate row is inserted, duplicate identity is rejected, required validation is enforced, and missing Validation lineage is rejected",

    context: "smoke",

    style_presentation_intent: null,

    exclusions: "No downstream lifecycle artifacts",

  });

  createGovernanceDelegation({

    delegation_id: delegationId,

    package_id: packageId,

    package_version: packageVersion,

    project_id: "hq",

    conversation_id: "conversation-governance-bridge",

    authorization_state: "authorized",

    delegated_by: "smoke-test",

  });

  createGovernanceValidationResult({

    validation_result_id: validationResultId,

    package_id: packageId,

    package_version: packageVersion,

    project_id: "hq",

    conversation_id: "conversation-governance-bridge",

    delegation_id: delegationId,

    validation_status: "ready",

  });

  const created = createGovernanceEnvelopeGate({

    envelope_gate_id: envelopeGateId,

    package_id: packageId,

    package_version: packageVersion,

    project_id: "hq",

    conversation_id: "conversation-governance-bridge",

    delegation_id: delegationId,

    validation_result_id: validationResultId,

    gate_status: "open",

    gate_reason: "Smoke gate eligibility record",

  });

  assert(created.envelope_gate_id === envelopeGateId, "created envelope_gate_id mismatch");

  assert(created.package_id === packageId, "created package_id mismatch");

  assert(created.package_version === packageVersion, "created package_version mismatch");

  assert(created.delegation_id === delegationId, "created delegation_id mismatch");

  assert(created.validation_result_id === validationResultId, "created validation_result_id mismatch");

  assert(created.gate_status === "open", "created gate_status mismatch");

  assert(typeof created.gate_decision_timestamp === "string" && created.gate_decision_timestamp.length > 0, "gate_decision_timestamp missing");

  assert(typeof created.created_at === "string" && created.created_at.length > 0, "created_at missing");

  const row = db

    .prepare(

      "SELECT envelope_gate_id, package_id, package_version, delegation_id, validation_result_id, gate_status FROM governance_envelope_gates WHERE envelope_gate_id = ?",

    )

    .get(envelopeGateId);

  assert(row, "Envelope Gate row was not persisted");

  assert(row.envelope_gate_id === envelopeGateId, "persisted envelope_gate_id mismatch");

  assert(row.package_id === packageId, "persisted package_id mismatch");

  assert(row.package_version === packageVersion, "persisted package_version mismatch");

  assert(row.delegation_id === delegationId, "persisted delegation_id mismatch");

  assert(row.validation_result_id === validationResultId, "persisted validation_result_id mismatch");

  assert(row.gate_status === "open", "persisted gate_status mismatch");

  let duplicateRejected = false;

  try {

    createGovernanceEnvelopeGate({

      envelope_gate_id: envelopeGateId,

      package_id: packageId,

      package_version: packageVersion,

      project_id: "hq",

      conversation_id: "conversation-governance-bridge",

      delegation_id: delegationId,

      validation_result_id: validationResultId,

      gate_status: "open",

    });

  } catch (err) {

    duplicateRejected = true;

  }

  assert(duplicateRejected, "Duplicate Envelope Gate identity was not rejected");

  let missingFieldRejected = false;

  try {

    createGovernanceEnvelopeGate({

      envelope_gate_id: "smoke-governance-envelope-gate-runtime-missing-field",

      package_id: packageId,

      package_version: packageVersion,

      project_id: "hq",

      conversation_id: "conversation-governance-bridge",

      delegation_id: delegationId,

      validation_result_id: validationResultId,

      gate_status: "",

    });

  } catch (err) {

    missingFieldRejected = true;

  }

  assert(missingFieldRejected, "Missing required field was not rejected");

  let missingValidationRejected = false;

  try {

    createGovernanceEnvelopeGate({

      envelope_gate_id: "smoke-governance-envelope-gate-runtime-missing-validation",

      package_id: packageId,

      package_version: packageVersion,

      project_id: "hq",

      conversation_id: "conversation-governance-bridge",

      delegation_id: delegationId,

      validation_result_id: "missing-governance-validation-result",

      gate_status: "open",

    });

  } catch (err) {

    missingValidationRejected = true;

  }

  assert(missingValidationRejected, "Missing Validation lineage was not rejected");

  cleanup();

  const remaining = db

    .prepare("SELECT COUNT(*) AS count FROM governance_envelope_gates WHERE envelope_gate_id = ?")

    .get(envelopeGateId);

  assert(remaining.count === 0, "Smoke test cleanup failed");

  console.log("PASS: governance Envelope Gate runtime smoke test passed");

} catch (err) {

  cleanup();

  console.error("FAIL: governance Envelope Gate runtime smoke test failed");

  console.error(err);

  process.exit(1);

}

