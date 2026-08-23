#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n=== CORRIDOR 1 · CANONICAL DELEGATION ENFORCEMENT BOUNDARY ===\n'
printf '%s\n' \
'CURRENT_CHECKPOINT=3be59232' \
'LEGACY_DELEGATION_PRESERVATION_REQUIRED=YES' \
'LEGACY_DELEGATION_CANONICAL_COUNTERPART=NO' \
'DIRECT_CANONICAL_ONLY_FK_REBUILD_SAFE=NO' \
'NEW_PRODUCTION_DELEGATION_CANONICAL_ROOT_REQUIRED=YES' \
'QUESTION=CAN_NEW_CREATION_BE_CANONICAL_ENFORCED_WITHOUT_INVENTING_A_NEW_PERSISTED_LINEAGE_TYPE'

printf '\n=== ALL DELEGATION CREATION CALLERS ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git \
-E 'createGovernanceDelegation\s*\(|persist.*Delegation|INSERT INTO governance_delegations' \
db server routes scripts 2>/dev/null | head -500

printf '\n=== GOVERNANCE DELEGATION INPUT TYPES ===\n'
grep -n -A90 -B30 \
-E 'CreateGovernanceDelegationInput|CreatedGovernanceDelegation|createGovernanceDelegation' \
db/governance-runtime.ts

printf '\n=== PRODUCTION ENTRY POINT ===\n'
sed -n '1,280p' server/delegation/production-delegation-entry-point.ts

printf '\n=== EXPLICIT DELEGATION ROUTE ===\n'
sed -n '1,280p' server/routes/governance-delegation-route.ts

printf '\n=== CANONICAL PACKAGE READ API ===\n'
grep -n -A130 -B30 \
-E 'getCanonical|CanonicalPackage|package_version' \
db/matilda-canonical-package-runtime.ts | head -500

printf '\n=== HISTORICAL CREATION EVIDENCE ===\n'
git log --all --oneline --decorate -- \
db/governance-runtime.ts \
server/delegation/production-delegation-entry-point.ts \
server/routes/governance-delegation-route.ts | head -150

printf '\n=== CURRENT LIVE IDENTITY RELATIONSHIP ===\n'
node <<'NODE'
const Database = require("better-sqlite3");
const db = new Database("db/main.db", { readonly: true });

console.log("\n=== DELEGATIONS WITH ROOT CLASSIFICATION ===");
console.log(
  db.prepare(`
    SELECT
      gd.delegation_id,
      gd.package_id,
      gd.package_version,
      CASE
        WHEN cp.package_id IS NOT NULL THEN 'CANONICAL'
        WHEN gp.package_id IS NOT NULL THEN 'LEGACY_GOVERNANCE_PACKAGE'
        ELSE 'ORPHAN'
      END AS root_class
    FROM governance_delegations gd
    LEFT JOIN matilda_canonical_packages cp
      ON cp.package_id = gd.package_id
     AND cp.package_version = gd.package_version
    LEFT JOIN governance_packages gp
      ON gp.package_id = gd.package_id
     AND gp.package_version = gd.package_version
    ORDER BY gd.created_at
  `).all()
);

console.log("\n=== CANONICAL PACKAGES AVAILABLE FOR NEW DELEGATION ===");
console.log(
  db.prepare(`
    SELECT
      package_id,
      package_version,
      status,
      approval_actor,
      approval_timestamp
    FROM matilda_canonical_packages
    ORDER BY package_id, package_version
  `).all()
);

db.close();
NODE

printf '\n=== CLASSIFICATION BOUNDARY ===\n'
printf '%s\n' \
'SCHEMA_CHANGE_PERFORMED=NO' \
'LEGACY_ROW_MUTATION_PERFORMED=NO' \
'NEW_LINEAGE_FIELD_ADDED=NO' \
'DELEGATION_CREATED=NO' \
'VALIDATION_CHANGE=NONE' \
'ENVELOPE_CHANGE=NONE' \
'ROUTING_CHANGE=NONE' \
'ASSIGNMENT_CHANGE=NONE' \
'EXECUTION_CHANGE=NONE'

printf '\n=== WORKTREE ===\n'
git status --short
