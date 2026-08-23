#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n=== GOVERNANCE RUNTIME ACTIVATION · CORRIDOR 1 RESUMPTION ===\n'
printf '%s\n' \
'CANONICAL_VERSION_IDENTITY_PREREQUISITE=CLOSED' \
'CORRIDOR=PRODUCTION_DELEGATION_PACKAGE_ROOT_RECONCILIATION' \
'IMPLEMENTATION_AUTHORIZED=YES' \
'QUESTION=WHAT_EXACT_CURRENT_SURFACE_MUST_CHANGE_TO_REANCHOR_DELEGATION_TO_VERSIONED_CANONICAL_PACKAGES'

printf '\n=== DELEGATION RUNTIME ===\n'
sed -n '1,320p' db/governance-delegation-runtime.ts 2>/dev/null || true

printf '\n=== DELEGATION ROUTES / CALLERS ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
-E 'governance_delegations|createDelegation|delegation.*package|package_version' \
db server routes 2>/dev/null | head -700

printf '\n=== LIVE DELEGATION SCHEMA ===\n'
node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

for (const table of [
  "governance_packages",
  "governance_delegations",
  "matilda_canonical_packages",
]) {
  console.log(`\n=== ${table} ===`);
  console.log(db.prepare(`PRAGMA table_info(${table})`).all());
  console.log(
    db.prepare(`
      SELECT sql
      FROM sqlite_master
      WHERE type = 'table'
        AND name = ?
    `).get(table)
  );
}

console.log("\n=== EXISTING DELEGATIONS ===");
console.log(
  db.prepare(`
    SELECT *
    FROM governance_delegations
    ORDER BY created_at
  `).all()
);

console.log("\n=== APPROVED CANONICAL PACKAGES ===");
console.log(
  db.prepare(`
    SELECT
      package_id,
      package_version,
      draft_revision_id,
      lineage_id,
      status,
      approval_timestamp
    FROM matilda_canonical_packages
    ORDER BY package_id, package_version
  `).all()
);

db.close();
NODE

printf '\n=== WORKTREE ===\n'
git status --short
