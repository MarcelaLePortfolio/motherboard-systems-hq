#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n=== CORRIDOR 1 · DELEGATION LEGACY PRESERVATION OPTIONS ===\n'
printf '%s\n' \
'CURRENT_CHECKPOINT=2ce8aeed' \
'IMPLEMENTATION_AUTHORIZED=YES' \
'LEGACY_CORRIDOR_SMOKE_CHAIN=INTERNALLY_CONSISTENT' \
'LEGACY_CORRIDOR_SMOKE_MUTATION_AUTHORIZED=NO' \
'PREEXISTING_DEMO_FK_VIOLATIONS=OUTSIDE_CURRENT_REANCHOR_SCOPE' \
'TARGET=NEW_DELEGATIONS_ROOTED_IN_MATILDA_CANONICAL_PACKAGES' \
'QUESTION=WHAT_MINIMUM_SCHEMA_PATTERN_PRESERVES_LEGACY_DELEGATION_WHILE_REQUIRING_CANONICAL_ROOT_FOR_NEW_DELEGATIONS'

printf '\n=== DELEGATION SCHEMA HISTORY ===\n'
git log --all --format='%H %ad %s' --date=iso -S'governance_delegations' -- db/governance-runtime.ts | head -120

printf '\n=== DELEGATION / PACKAGE ROOT DOCTRINE ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
-E 'Delegation.*Package|Package.*Delegation|governance_packages|matilda_canonical_packages|Canonical Package.*Delegation|Delegation.*Canonical Package|legacy.*Delegation|historical.*Delegation' \
docs/governance db server 2>/dev/null | head -600

printf '\n=== SQLITE TABLE REBUILD / MIGRATION PRECEDENTS ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
-E 'ALTER TABLE.*RENAME|CREATE TABLE.*_new|PRAGMA foreign_keys|foreign_key_check|DROP TABLE.*governance|INSERT INTO.*SELECT' \
db scripts 2>/dev/null | head -500

printf '\n=== DELEGATION READERS AND JOIN ASSUMPTIONS ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
-E 'FROM governance_delegations|JOIN governance_delegations|governance_delegations gd|delegation_id.*package_id|package_id.*package_version' \
db server routes 2>/dev/null | head -600

printf '\n=== CURRENT TABLE SQL ===\n'
node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

for (const table of [
  "governance_delegations",
  "governance_validation_results",
  "governance_envelope_gates",
  "governance_envelopes",
  "matilda_canonical_packages",
]) {
  console.log(`\n=== ${table} ===`);
  console.log(
    db.prepare(`
      SELECT sql
      FROM sqlite_master
      WHERE type = 'table'
        AND name = ?
    `).get(table)
  );
}

console.log("\n=== LEGACY DELEGATION COUNT ===");
console.log(
  db.prepare(`
    SELECT COUNT(*) AS count
    FROM governance_delegations
  `).get()
);

console.log("\n=== LEGACY DELEGATIONS WITHOUT CANONICAL ROOT ===");
console.log(
  db.prepare(`
    SELECT gd.*
    FROM governance_delegations gd
    LEFT JOIN matilda_canonical_packages cp
      ON cp.package_id = gd.package_id
     AND cp.package_version = gd.package_version
    WHERE cp.package_id IS NULL
  `).all()
);

db.close();
NODE

printf '\n=== BOUNDARY ===\n'
printf '%s\n' \
'SCHEMA_CHANGE_PERFORMED=NO' \
'LEGACY_ROW_MUTATION_PERFORMED=NO' \
'DELEGATION_CREATED=NO' \
'VALIDATION_CHANGE=NONE' \
'ENVELOPE_CHANGE=NONE' \
'ROUTING_CHANGE=NONE' \
'ASSIGNMENT_CHANGE=NONE' \
'EXECUTION_CHANGE=NONE'

printf '\n=== WORKTREE ===\n'
git status --short
