#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n=== CANONICAL DELEGATION ROOT · VALIDATION ===\n'
printf '%s\n' \
'CURRENT_CHECKPOINT=bccd6030' \
'QUESTION=DO_NEW_DELEGATIONS_REQUIRE_AN_EXISTING_CANONICAL_PACKAGE_WHILE_LEGACY_HISTORY_REMAINS_UNCHANGED'

node -r ts-node/register <<'NODE'
const Database = require("better-sqlite3");
const {
  createGovernanceDelegation,
} = require("./db/governance-runtime");

const db = new Database("db/main.db");

const canonical = db.prepare(`
  SELECT
    package_id,
    package_version
  FROM matilda_canonical_packages
  WHERE status = 'canonical_approved'
  ORDER BY package_version DESC
  LIMIT 1
`).get();

if (!canonical) {
  throw new Error("No approved Canonical Package is available for Delegation validation.");
}

const historicalBefore = db.prepare(`
  SELECT *
  FROM governance_delegations
  WHERE delegation_id = 'corridor-delegation'
`).get();

if (!historicalBefore) {
  throw new Error("Historical corridor-smoke Delegation is missing before validation.");
}

const validationDelegationId = `canonical-root-validation-${Date.now()}`;

try {
  const created = createGovernanceDelegation({
    delegation_id: validationDelegationId,
    package_id: canonical.package_id,
    package_version: canonical.package_version,
    authorization_state: "AUTHORIZED",
    authorization_timestamp: new Date().toISOString(),
    delegated_by: "marcela",
  });

  console.log("\n=== CANONICAL CREATION ===");
  console.log(created);

  if (
    created.package_id !== canonical.package_id ||
    created.package_version !== canonical.package_version
  ) {
    throw new Error("Created Delegation did not retain exact Canonical Package identity.");
  }

  console.log("CANONICAL_PACKAGE_DELEGATION=PASS");

  let legacyRejected = false;

  try {
    createGovernanceDelegation({
      delegation_id: `legacy-root-rejection-${Date.now()}`,
      package_id: "corridor-smoke",
      package_version: 1,
      authorization_state: "AUTHORIZED",
      authorization_timestamp: new Date().toISOString(),
      delegated_by: "marcela",
    });
  } catch (error) {
    legacyRejected = /existing Canonical Package version/i.test(
      error instanceof Error ? error.message : String(error)
    );

    console.log("\n=== LEGACY NEW-CREATION REJECTION ===");
    console.log(error instanceof Error ? error.message : String(error));
  }

  if (!legacyRejected) {
    throw new Error(
      "New Delegation creation against legacy governance_packages was not rejected."
    );
  }

  console.log("LEGACY_ROOT_NEW_DELEGATION_REJECTED=PASS");

  const historicalAfter = db.prepare(`
    SELECT *
    FROM governance_delegations
    WHERE delegation_id = 'corridor-delegation'
  `).get();

  if (
    JSON.stringify(historicalAfter) !== JSON.stringify(historicalBefore)
  ) {
    throw new Error("Historical corridor-smoke Delegation changed during validation.");
  }

  console.log("HISTORICAL_DELEGATION_PRESERVED=PASS");
} finally {
  db.prepare(`
    DELETE FROM governance_delegations
    WHERE delegation_id = ?
  `).run(validationDelegationId);

  db.close();
}
NODE

printf '\n=== WORKTREE ===\n'
git status --short
