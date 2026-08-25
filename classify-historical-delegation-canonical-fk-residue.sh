#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== HISTORICAL DELEGATION CANONICAL FK RESIDUE CLASSIFICATION ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== FULL FOREIGN KEY CHECK ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_check;"

echo
echo "=== HISTORICAL DELEGATION ROW ==="
sqlite3 -header -column db/main.db "
SELECT
  d.delegation_id,
  d.package_id,
  d.package_version,
  d.authorization_state,
  d.authorization_timestamp,
  d.delegated_by,
  d.created_at,
  CASE WHEN gp.package_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS legacy_package_exists,
  CASE WHEN cp.package_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS canonical_package_exists
FROM governance_delegations d
LEFT JOIN governance_packages gp
  ON gp.package_id = d.package_id
 AND gp.package_version = d.package_version
LEFT JOIN matilda_canonical_packages cp
  ON cp.package_id = d.package_id
 AND cp.package_version = d.package_version
WHERE d.delegation_id = 'corridor-delegation';
"

echo
echo "=== CURRENT DELEGATION FK CONTRACT ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_list(governance_delegations);"
sqlite3 db/main.db ".schema governance_delegations"

echo
echo "=== DELEGATION MIGRATION VALIDATION ==="
sed -n '1,180p' scripts/validate-canonical-delegation-root.sh

echo
echo "=== DELEGATION SCHEMA STABILITY VALIDATION ==="
sed -n '1,180p' scripts/verify-delegation-reanchor-schema-stability.sh 2>/dev/null || true

echo
echo "=== RECONCILIATION CLOSURE HISTORICAL CLAIM ==="
sed -n '1,120p' docs/governance/PRODUCTION_DELEGATION_PACKAGE_ROOT_RECONCILIATION_CLOSURE_2026-08-23.md

echo
echo "=== DELEGATION MIGRATION IMPLEMENTATION ==="
sed -n '1,180p' scripts/migrate-delegation-root-to-canonical.sh

echo
echo "=== SEARCH FOR EXPLICIT TOLERANCE OF FK-VIOLATING HISTORICAL ROW ==="
rg -n -C 10 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'foreign_key_check|foreign key violation|FK violation|historical.*foreign key|foreign key.*historical|corridor-delegation.*historical|historical.*corridor-delegation|tolerat.*historical|historical.*tolerat' \
  docs scripts db drizzle \
  2>/dev/null | head -n 1400

echo
echo "=== SEARCH FOR RUNTIME ACCESS TO HISTORICAL DELEGATION ==="
rg -n -C 10 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'corridor-delegation|governance_delegations' \
  db server routes scripts \
  2>/dev/null | head -n 1400

echo
echo "=== CANONICAL DELEGATION CREATION GUARD ==="
rg -n -C 20 \
  'createGovernanceDelegation|matilda_canonical_packages|Canonical Package|authorization_state' \
  db/governance-runtime.ts \
  server/delegation \
  server/routes \
  2>/dev/null | head -n 1200

echo
echo "=== CLASSIFICATION ==="
echo "HISTORICAL_DELEGATION_ID=corridor-delegation"
echo "HISTORICAL_DELEGATION_PACKAGE=corridor-smoke@1"
echo "LEGACY_PACKAGE_EXISTS=YES"
echo "CANONICAL_PACKAGE_EXISTS=NO"
echo "CURRENT_DELEGATION_TABLE_ROOT=MATILDA_CANONICAL_PACKAGES"
echo "HISTORICAL_DELEGATION_VIOLATES_DECLARED_CANONICAL_FK=YES"
echo "ROW_WAS_COPIED_WITH_FOREIGN_KEYS_DISABLED=YES"
echo "DOCUMENTED_HISTORICAL_PRESERVATION=YES"
echo "DOCUMENTED_PERMISSION_FOR_FK_VIOLATION=NOT_YET_ESTABLISHED"
echo "STALE_DOWNSTREAM_DELEGATION_FKS_CAN_BE_REPAIRED_SAFELY=NO_NOT_WHILE_PARENT_ROW_ITSELF_VIOLATES_DECLARED_ROOT"
echo "VALIDATION_ROOT_RECONCILIATION_READY=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=DETERMINE_WHETHER_HISTORICAL_DELEGATION_PRESERVATION_REQUIRES_AN_EXPLICIT_NONAUTHORITATIVE_HISTORICAL_SURFACE_OR_OTHER_REPOSITORY_INTEGRITY_RECONCILIATION_BEFORE_DOWNSTREAM_CANONICAL_LINEAGE_CONTINUES"
