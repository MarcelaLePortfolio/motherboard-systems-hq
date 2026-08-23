#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n=== CORRIDOR 1 · DELEGATION REANCHOR MIGRATION BOUNDARY ===\n'
printf '%s\n' \
'CURRENT_CHECKPOINT=7ffb4f46' \
'PRODUCTION_DELEGATION_IDENTITY_TRANSPORT=ALREADY_PACKAGE_ID_PLUS_PACKAGE_VERSION' \
'CURRENT_PERSISTENCE_ROOT=GOVERNANCE_PACKAGES' \
'TARGET_AUTHORITATIVE_ROOT=MATILDA_CANONICAL_PACKAGES' \
'LEGACY_SMOKE_LINEAGE_PRESERVE=YES' \
'QUESTION=CAN_DELEGATION_PERSISTENCE_BE_REANCHORED_WITHOUT_BREAKING_EXISTING_DOWNSTREAM_LINEAGE'

node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

const tables = [
  "governance_packages",
  "governance_delegations",
  "governance_validation_results",
  "governance_envelope_gates",
  "governance_envelopes",
  "matilda_canonical_packages",
];

for (const table of tables) {
  console.log(`\n=== ${table} · FOREIGN KEYS ===`);
  console.log(db.prepare(`PRAGMA foreign_key_list(${table})`).all());

  console.log(`\n=== ${table} · ROWS ===`);
  try {
    console.log(db.prepare(`SELECT * FROM ${table}`).all());
  } catch (error) {
    console.log(`READ_FAILED=${error.message}`);
  }
}

console.log("\n=== FOREIGN KEY CHECK ===");
console.log(db.prepare("PRAGMA foreign_key_check").all());

console.log("\n=== CORRIDOR SMOKE PACKAGE ===");
console.log(
  db.prepare(`
    SELECT *
    FROM governance_packages
    WHERE package_id = 'corridor-smoke'
      AND package_version = 1
  `).all()
);

console.log("\n=== CORRIDOR SMOKE DELEGATION ===");
console.log(
  db.prepare(`
    SELECT *
    FROM governance_delegations
    WHERE package_id = 'corridor-smoke'
      AND package_version = 1
  `).all()
);

for (const table of [
  "governance_validation_results",
  "governance_envelope_gates",
  "governance_envelopes",
]) {
  console.log(`\n=== ${table} · CORRIDOR SMOKE DEPENDENTS ===`);
  console.log(
    db.prepare(`
      SELECT *
      FROM ${table}
      WHERE package_id = 'corridor-smoke'
        AND package_version = 1
    `).all()
  );
}

console.log("\n=== AUTHORITATIVE CANONICAL IDENTITY ===");
console.log(
  db.prepare(`
    SELECT
      package_id,
      package_version,
      lineage_id,
      status,
      approval_timestamp
    FROM matilda_canonical_packages
    ORDER BY package_id, package_version
  `).all()
);

db.close();
NODE

printf '\n=== RELEVANT SCHEMA DEFINITIONS ===\n'
sed -n '205,315p' db/governance-runtime.ts

printf '\n=== DELEGATION PERSISTENCE FUNCTION ===\n'
sed -n '690,785p' db/governance-runtime.ts

printf '\n=== WORKTREE ===\n'
git status --short
