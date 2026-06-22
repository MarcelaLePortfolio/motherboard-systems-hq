
import fs from "node:fs";

import Database from "better-sqlite3";

const packageId = "smoke-governance-envelope-runtime-package";

const packageVersion = 1;

const delegationId = "smoke-governance-envelope-runtime-delegation";

const validationResultId = "smoke-governance-envelope-runtime-validation";

const envelopeGateId = "smoke-governance-envelope-runtime-gate";

const envelopeId = "smoke-governance-envelope-runtime";

const dbPath = "db/main.db";

const migrationPath = "drizzle/0004_governance_lifecycle_artifacts.sql";

const sqlite = new Database(dbPath);

sqlite.pragma("foreign_keys = ON");

sqlite.exec(fs.readFileSync(migrationPath, "utf8"));

const {

  createGovernancePackage,

  createGovernanceDelegation,

  createGovernanceValidationResult,

  createGovernanceEnvelopeGate,

  createGovernanceEnvelope,

} = await import("../db/governance-runtime.ts");

function cleanup() {

  sqlite.prepare("DELETE FROM governance_envelopes WHERE envelope_id = ?").run(envelopeId);

  sqlite.prepare("DELETE FROM governance_envelopes WHERE envelope_id = ?").run("smoke-governance-envelope-runtime-missing-field");

  sqlite.prepare("DELETE FROM governance_envelopes WHERE envelope_id = ?").run("smoke-governance-envelope-runtime-missing-gate");

  sqlite.prepare("DELETE FROM governance_envelope_gates WHERE envelope_gate_id = ?").run(envelopeGateId);

  sqlite.prepare("DELETE FROM governance_validation_results WHERE validation_result_id = ?").run(validationResultId);

  sqlite.prepare("DELETE FROM governance_delegations WHERE delegation_id = ?").run(delegationId);

  sqlite.prepare("DELETE FROM governance_packages WHERE package_id = ? AND package_version = ?").run(packageId, packageVersion);

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

    requested_outcome: "Provide Package lineage for governance Envelope runtime smoke validation",

    scope: "Envelope runtime smoke test only",

    containment: "No routing, assignment, execution, automation, or agent invocation",

    constraints: "Reversible test data only",

    success_criteria: "Envelope row is inserted, duplicate identity is rejected, required validation is enforced, and missing Gate lineage is rejected",

    context: "smoke",

    style_presentation_intent: null,

    exclusions: "No downstream execution behavior",

  });

  createGovernanceDelegation({

    delegation_id: delegationId,

    package_id: packageId,

    package_version: packageVersion,

    authorization_state: "authorized",

    delegated_by: "smoke-test",

  });

  createGovernanceValidationResult({

    validation_result_id: validationResultId,

    package_id: packageId,

    package_version: packageVersion,

    delegation_id: delegationId,

    validation_status: "ready",

  });

  createGovernanceEnvelopeGate({

    envelope_gate_id: envelopeGateId,

    package_id: packageId,

    package_version: packageVersion,

    delegation_id: delegationId,

    validation_result_id: validationResultId,

    gate_status: "open",

    gate_reason: "Smoke gate eligibility record",

  });

  const created = createGovernanceEnvelope({

    envelope_id: envelopeId,

    package_id: packageId,

    package_version: packageVersion,

    delegation_id: delegationId,

    validation_result_id: validationResultId,

    envelope_gate_id: envelopeGateId,

    validation_status: "ready",

    required_capabilities: "Smoke capability",

    operational_corridor: "Smoke operational corridor",

    lifecycle_state: "authorized",

  });

  assert(created.envelope_id === envelopeId, "created envelope_id mismatch");

  assert(created.package_id === packageId, "created package_id mismatch");

  assert(created.package_version === packageVersion, "created package_version mismatch");

  assert(created.delegation_id === delegationId, "created delegation_id mismatch");

  assert(created.validation_result_id === validationResultId, "created validation_result_id mismatch");

  assert(created.envelope_gate_id === envelopeGateId, "created envelope_gate_id mismatch");

  assert(created.validation_status === "ready", "created validation_status mismatch");

  assert(created.lifecycle_state === "authorized", "created lifecycle_state mismatch");

  assert(typeof created.created_at === "string" && created.created_at.length > 0, "created_at missing");

  const row = sqlite

    .prepare(

      "SELECT envelope_id, package_id, package_version, delegation_id, validation_result_id, envelope_gate_id, validation_status, lifecycle_state FROM governance_envelopes WHERE envelope_id = ?",

    )

    .get(envelopeId);

  assert(row, "Envelope row was not persisted");

  assert(row.envelope_id === envelopeId, "persisted envelope_id mismatch");

  assert(row.package_id === packageId, "persisted package_id mismatch");

  assert(row.package_version === packageVersion, "persisted package_version mismatch");

  assert(row.delegation_id === delegationId, "persisted delegation_id mismatch");

  assert(row.validation_result_id === validationResultId, "persisted validation_result_id mismatch");

  assert(row.envelope_gate_id === envelopeGateId, "persisted envelope_gate_id mismatch");

  assert(row.validation_status === "ready", "persisted validation_status mismatch");

  assert(row.lifecycle_state === "authorized", "persisted lifecycle_state mismatch");

  let duplicateRejected = false;

  try {

    createGovernanceEnvelope({

      envelope_id: envelopeId,

      package_id: packageId,

      package_version: packageVersion,

      delegation_id: delegationId,

      validation_result_id: validationResultId,

      envelope_gate_id: envelopeGateId,

      validation_status: "ready",

      lifecycle_state: "authorized",

    });

  } catch (err) {

    duplicateRejected = true;

  }

  assert(duplicateRejected, "Duplicate Envelope identity was not rejected");

  let missingFieldRejected = false;

  try {

    createGovernanceEnvelope({

      envelope_id: "smoke-governance-envelope-runtime-missing-field",

      package_id: packageId,

      package_version: packageVersion,

      delegation_id: delegationId,

      validation_result_id: validationResultId,

      envelope_gate_id: envelopeGateId,

      validation_status: "",

      lifecycle_state: "authorized",

    });

  } catch (err) {

    missingFieldRejected = true;

  }

  assert(missingFieldRejected, "Missing required field was not rejected");

  let missingGateRejected = false;

  try {

    createGovernanceEnvelope({

      envelope_id: "smoke-governance-envelope-runtime-missing-gate",

      package_id: packageId,

      package_version: packageVersion,

      delegation_id: delegationId,

      validation_result_id: validationResultId,

      envelope_gate_id: "missing-governance-envelope-gate",

      validation_status: "ready",

      lifecycle_state: "authorized",

    });

  } catch (err) {

    missingGateRejected = true;

  }

  assert(missingGateRejected, "Missing Envelope Gate lineage was not rejected");

  cleanup();

  const remaining = sqlite

    .prepare("SELECT COUNT(*) AS count FROM governance_envelopes WHERE envelope_id = ?")

    .get(envelopeId);

  assert(remaining.count === 0, "Smoke test cleanup failed");

  console.log("PASS: governance Envelope runtime smoke test passed");

} catch (err) {

  cleanup();

  console.error("FAIL: governance Envelope runtime smoke test failed");

  console.error(err);

  process.exit(1);

}

