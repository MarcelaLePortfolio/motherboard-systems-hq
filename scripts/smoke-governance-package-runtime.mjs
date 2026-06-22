
import fs from "node:fs";

import Database from "better-sqlite3";

const packageId = "smoke-governance-package-runtime";

const packageVersion = 1;

const dbPath = "db/main.db";

const migrationPath = "drizzle/0004_governance_lifecycle_artifacts.sql";

const sqlite = new Database(dbPath);

sqlite.pragma("foreign_keys = ON");

sqlite.exec(fs.readFileSync(migrationPath, "utf8"));

const { createGovernancePackage } = await import("../db/governance-runtime.ts");

function cleanup() {

  sqlite

    .prepare(

      "DELETE FROM governance_packages WHERE package_id = ? AND package_version = ?",

    )

    .run(packageId, packageVersion);

  sqlite

    .prepare(

      "DELETE FROM governance_packages WHERE package_id = ? AND package_version = ?",

    )

    .run("smoke-governance-package-runtime-missing-field", 1);

}

function assert(condition, message) {

  if (!condition) {

    throw new Error(message);

  }

}

try {

  cleanup();

  const created = createGovernancePackage({

    package_id: packageId,

    package_version: packageVersion,

    requested_outcome: "Verify DB-only governance Package runtime creation",

    scope: "Package runtime smoke test only",

    containment: "No routes, UI, delegation, validation, gates, envelopes, routing, assignment, or execution",

    constraints: "Reversible test data only",

    success_criteria: "Package row is inserted, duplicate identity is rejected, required validation is enforced",

    context: "smoke",

    style_presentation_intent: null,

    exclusions: "No downstream lifecycle artifacts",

  });

  assert(created.package_id === packageId, "created package_id mismatch");

  assert(created.package_version === packageVersion, "created package_version mismatch");

  assert(typeof created.created_at === "string" && created.created_at.length > 0, "created_at missing");

  const row = sqlite

    .prepare(

      "SELECT package_id, package_version, requested_outcome FROM governance_packages WHERE package_id = ? AND package_version = ?",

    )

    .get(packageId, packageVersion);

  assert(row, "Package row was not persisted");

  assert(row.package_id === packageId, "persisted package_id mismatch");

  assert(row.package_version === packageVersion, "persisted package_version mismatch");

  let duplicateRejected = false;

  try {

    createGovernancePackage({

      package_id: packageId,

      package_version: packageVersion,

      requested_outcome: "Duplicate should fail",

      scope: "Duplicate smoke",

      containment: "Duplicate smoke",

      constraints: "Duplicate smoke",

      success_criteria: "Duplicate rejected",

    });

  } catch (err) {

    duplicateRejected = true;

  }

  assert(duplicateRejected, "Duplicate package identity was not rejected");

  let missingFieldRejected = false;

  try {

    createGovernancePackage({

      package_id: "smoke-governance-package-runtime-missing-field",

      package_version: 1,

      requested_outcome: "",

      scope: "Missing field smoke",

      containment: "Missing field smoke",

      constraints: "Missing field smoke",

      success_criteria: "Missing field rejected",

    });

  } catch (err) {

    missingFieldRejected = true;

  }

  assert(missingFieldRejected, "Missing required field was not rejected");

  cleanup();

  const remaining = sqlite

    .prepare(

      "SELECT COUNT(*) AS count FROM governance_packages WHERE package_id = ? AND package_version = ?",

    )

    .get(packageId, packageVersion);

  assert(remaining.count === 0, "Smoke test cleanup failed");

  console.log("PASS: governance Package runtime smoke test passed");

} catch (err) {

  cleanup();

  console.error("FAIL: governance Package runtime smoke test failed");

  console.error(err);

  process.exit(1);

}

