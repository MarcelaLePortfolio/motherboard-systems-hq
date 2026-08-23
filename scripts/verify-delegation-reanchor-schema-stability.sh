#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n=== DELEGATION REANCHOR · SCHEMA STABILITY VALIDATION ===\n'
printf '%s\n' \
'CURRENT_CHECKPOINT=7c6b87f2' \
'LIVE_CANONICAL_DELEGATION=PASS' \
'LEGACY_NEW_DELEGATION_REJECTED=PASS' \
'HISTORICAL_DELEGATION_PRESERVED=PASS' \
'QUESTION=DOES_GOVERNANCE_RUNTIME_INITIALIZATION_PRESERVE_THE_NEW_CANONICAL_FOREIGN_KEY'

printf '\n=== BEFORE INITIALIZATION ===\n'
node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });
console.log(db.prepare("PRAGMA foreign_key_list(governance_delegations)").all());
db.close();
NODE

printf '\n=== RUN GOVERNANCE INITIALIZATION ===\n'
node -r ts-node/register <<'NODE'
const {
  ensureGovernanceRuntimeTables,
} = require("./db/governance-runtime");

ensureGovernanceRuntimeTables();
console.log("GOVERNANCE_RUNTIME_INITIALIZATION=PASS");
NODE

printf '\n=== AFTER INITIALIZATION ===\n'
node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

const foreignKeys = db
  .prepare("PRAGMA foreign_key_list(governance_delegations)")
  .all();

console.log(foreignKeys);

const parents = [...new Set(foreignKeys.map((row) => row.table))];

if (
  parents.length !== 1 ||
  parents[0] !== "matilda_canonical_packages"
) {
  throw new Error(
    `Delegation persistence root drifted after initialization: ${parents.join(", ")}`
  );
}

console.log("CANONICAL_DELEGATION_ROOT_AFTER_INITIALIZATION=PASS");

const historical = db.prepare(`
  SELECT *
  FROM governance_delegations
  WHERE delegation_id = 'corridor-delegation'
`).get();

if (!historical) {
  throw new Error("Historical corridor-smoke Delegation was not preserved.");
}

console.log("HISTORICAL_DELEGATION_STILL_PRESENT=PASS");

db.close();
NODE

printf '\n=== SOURCE SCHEMA DEFINITION ===\n'
sed -n '228,250p' db/governance-runtime.ts

printf '\n=== WORKTREE ===\n'
git status --short
