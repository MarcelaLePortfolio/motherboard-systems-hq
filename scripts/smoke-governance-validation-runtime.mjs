
import fs from "node:fs";

import Database from "better-sqlite3";

const packageId = "smoke-governance-validation-runtime-package";

const packageVersion = 1;

const delegationId = "smoke-governance-validation-runtime-delegation";

const validationResultId = "smoke-governance-validation-runtime";

const dbPath = "db/main.db";

const migrationPath = "drizzle/0004_governance_lifecycle_artifacts.sql";

const db = new Database(dbPath);

db.pragma("foreign_keys = ON");

db.exec(fs.readFileSync(migrationPath, "utf8"));

const {

  createGovernancePackage,

  createGovernanceDelegation,

  createGovernanceValidationResult,

} = await import("../db/governance-runtime.ts");

function cleanup() {

  db.prepare("DELETE FROM governance_validation_results WHERE validation_result_id = ?").run(validationResultId);

  db.prepare("DELETE FROM governance_validation_results WHERE validation_result_id = ?").run("smoke-governance-validation-runtime-missing-field");

  db.prepare("DELETE FROM governance_validation_results WHERE validation_result_id = ?").run("smoke-governance-validation-runtime-missing-delegation");

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

    requested_outcome: "Provide Package lineage for governance Validation runtime smoke validation",

    scope: "Validation runtime smoke test only",

    containment: "No gate, envelope, routing, assignment, execution, automation, or agent invocation",

    constraints: "Reversible test data only",

    success_criteria: "Validation row is inserted, duplicate identity is rejected, required validation is enforced, and missing Delegation lineage is rejected",

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

  const created = createGovernanceValidationResult({

    validation_result_id: validationResultId,

    package_id: packageId,

    package_version: packageVersion,

    project_id: "hq",

    conversation_id: "conversation-governance-bridge",

    delegation_id: delegationId,

    validation_status: "ready",

    governance_findings: "Smoke governance finding",

    operational_requirements: "Smoke operational requirement",

    capability_requirements: "Smoke capability requirement",

    escalations: null,

  });

  assert(created.validation_result_id === validationResultId, "created validation_result_id mismatch");

  assert(created.package_id === packageId, "created package_id mismatch");

  assert(created.package_version === packageVersion, "created package_version mismatch");

  assert(created.delegation_id === delegationId, "created delegation_id mismatch");

  assert(created.validation_status === "ready", "created validation_status mismatch");

  assert(typeof created.validation_timestamp === "string" && created.validation_timestamp.length > 0, "validation_timestamp missing");

  assert(typeof created.created_at === "string" && created.created_at.length > 0, "created_at missing");

  const row = db

    .prepare(

      "SELECT validation_result_id, package_id, package_version, delegation_id, validation_status FROM governance_validation_results WHERE validation_result_id = ?",

    )

    .get(validationResultId);

  assert(row, "Validation row was not persisted");

  assert(row.validation_result_id === validationResultId, "persisted validation_result_id mismatch");

  assert(row.package_id === packageId, "persisted package_id mismatch");

  assert(row.package_version === packageVersion, "persisted package_version mismatch");

  assert(row.delegation_id === delegationId, "persisted delegation_id mismatch");

  assert(row.validation_status === "ready", "persisted validation_status mismatch");

  let duplicateRejected = false;

  try {

    createGovernanceValidationResult({

      validation_result_id: validationResultId,

      package_id: packageId,

      package_version: packageVersion,

      project_id: "hq",

      conversation_id: "conversation-governance-bridge",

      delegation_id: delegationId,

      validation_status: "ready",

    });

  } catch (err) {

    duplicateRejected = true;

  }

  assert(duplicateRejected, "Duplicate validation identity was not rejected");

  let missingFieldRejected = false;

  try {

    createGovernanceValidationResult({

      validation_result_id: "smoke-governance-validation-runtime-missing-field",

      package_id: packageId,

      package_version: packageVersion,

      project_id: "hq",

      conversation_id: "conversation-governance-bridge",

      delegation_id: delegationId,

      validation_status: "",

    });

  } catch (err) {

    missingFieldRejected = true;

  }

  assert(missingFieldRejected, "Missing required field was not rejected");

  let missingDelegationRejected = false;

  try {

    createGovernanceValidationResult({

      validation_result_id: "smoke-governance-validation-runtime-missing-delegation",

      package_id: packageId,

      package_version: packageVersion,

      project_id: "hq",

      conversation_id: "conversation-governance-bridge",

      delegation_id: "missing-governance-delegation",

      validation_status: "ready",

    });

  } catch (err) {

    missingDelegationRejected = true;

  }

  assert(missingDelegationRejected, "Missing Delegation lineage was not rejected");

  cleanup();

  const remaining = db

    .prepare("SELECT COUNT(*) AS count FROM governance_validation_results WHERE validation_result_id = ?")

    .get(validationResultId);

  assert(remaining.count === 0, "Smoke test cleanup failed");

  console.log("PASS: governance Validation runtime smoke test passed");

} catch (err) {

  cleanup();

  console.error("FAIL: governance Validation runtime smoke test failed");

  console.error(err);

  process.exit(1);

}

