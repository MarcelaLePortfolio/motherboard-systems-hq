
import fs from "node:fs";

import Database from "better-sqlite3";

const packageId = "smoke-governance-delegation-runtime-package";

const packageVersion = 1;

const delegationId = "smoke-governance-delegation-runtime";

const dbPath = "db/main.db";

const migrationPath = "drizzle/0004_governance_lifecycle_artifacts.sql";

const db = new Database(dbPath);

sqlite.pragma("foreign_keys = ON");

sqlite.exec(fs.readFileSync(migrationPath, "utf8"));

const { createGovernancePackage, createGovernanceDelegation } = await import("../db/governance-runtime.ts");

function cleanup() {

  sqlite.prepare("DELETE FROM governance_delegations WHERE delegation_id = ?").run(delegationId);

  sqlite.prepare("DELETE FROM governance_delegations WHERE delegation_id = ?").run("smoke-governance-delegation-runtime-missing-field");

  sqlite.prepare("DELETE FROM governance_delegations WHERE delegation_id = ?").run("smoke-governance-delegation-runtime-missing-package");

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

    requested_outcome: "Provide Package lineage for governance Delegation runtime smoke validation",

    scope: "Delegation runtime smoke test only",

    containment: "No validation, gate, envelope, routing, assignment, or execution",

    constraints: "Reversible test data only",

    success_criteria: "Delegation row is inserted, duplicate identity is rejected, required validation is enforced, and missing Package lineage is rejected",

    context: "smoke",

    style_presentation_intent: null,

    exclusions: "No downstream lifecycle artifacts",

  });

  const created = createGovernanceDelegation({

    delegation_id: delegationId,

    package_id: packageId,

    package_version: packageVersion,

    authorization_state: "authorized",

    delegated_by: "smoke-test",

  });

  assert(created.delegation_id === delegationId, "created delegation_id mismatch");

  assert(created.package_id === packageId, "created package_id mismatch");

  assert(created.package_version === packageVersion, "created package_version mismatch");

  assert(created.authorization_state === "authorized", "created authorization_state mismatch");

  assert(created.delegated_by === "smoke-test", "created delegated_by mismatch");

  assert(typeof created.authorization_timestamp === "string" && created.authorization_timestamp.length > 0, "authorization_timestamp missing");

  assert(typeof created.created_at === "string" && created.created_at.length > 0, "created_at missing");

  const row = db

    .prepare(

      "SELECT delegation_id, package_id, package_version, authorization_state, delegated_by FROM governance_delegations WHERE delegation_id = ?",

    )

    .get(delegationId);

  assert(row, "Delegation row was not persisted");

  assert(row.delegation_id === delegationId, "persisted delegation_id mismatch");

  assert(row.package_id === packageId, "persisted package_id mismatch");

  assert(row.package_version === packageVersion, "persisted package_version mismatch");

  assert(row.authorization_state === "authorized", "persisted authorization_state mismatch");

  assert(row.delegated_by === "smoke-test", "persisted delegated_by mismatch");

  let duplicateRejected = false;

  try {

    createGovernanceDelegation({

      delegation_id: delegationId,

      package_id: packageId,

      package_version: packageVersion,

      authorization_state: "authorized",

      delegated_by: "smoke-test",

    });

  } catch (err) {

    duplicateRejected = true;

  }

  assert(duplicateRejected, "Duplicate delegation identity was not rejected");

  let missingFieldRejected = false;

  try {

    createGovernanceDelegation({

      delegation_id: "smoke-governance-delegation-runtime-missing-field",

      package_id: packageId,

      package_version: packageVersion,

      authorization_state: "",

      delegated_by: "smoke-test",

    });

  } catch (err) {

    missingFieldRejected = true;

  }

  assert(missingFieldRejected, "Missing required field was not rejected");

  let missingPackageRejected = false;

  try {

    createGovernanceDelegation({

      delegation_id: "smoke-governance-delegation-runtime-missing-package",

      package_id: "missing-governance-package",

      package_version: 1,

      authorization_state: "authorized",

      delegated_by: "smoke-test",

    });

  } catch (err) {

    missingPackageRejected = true;

  }

  assert(missingPackageRejected, "Missing Package lineage was not rejected");

  cleanup();

  const remaining = db

    .prepare("SELECT COUNT(*) AS count FROM governance_delegations WHERE delegation_id = ?")

    .get(delegationId);

  assert(remaining.count === 0, "Smoke test cleanup failed");

  console.log("PASS: governance Delegation runtime smoke test passed");

} catch (err) {

  cleanup();

  console.error("FAIL: governance Delegation runtime smoke test failed");

  console.error(err);

  process.exit(1);

}

