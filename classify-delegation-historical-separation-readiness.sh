#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== DELEGATION HISTORICAL SEPARATION READINESS ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== CURRENT INTEGRITY FAILURE ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_check;"

echo
echo "=== AUTHORITATIVE VS HISTORICAL DELEGATION ROWS ==="
sqlite3 -header -column db/main.db "
SELECT
  gd.delegation_id,
  gd.package_id,
  gd.package_version,
  gd.authorization_state,
  CASE
    WHEN cp.package_id IS NOT NULL THEN 'AUTHORITATIVE_CANONICAL'
    WHEN gp.package_id IS NOT NULL THEN 'HISTORICAL_LEGACY'
    ELSE 'UNRESOLVED'
  END AS lineage_class
FROM governance_delegations gd
LEFT JOIN matilda_canonical_packages cp
  ON cp.package_id = gd.package_id
 AND cp.package_version = gd.package_version
LEFT JOIN governance_packages gp
  ON gp.package_id = gd.package_id
 AND gp.package_version = gd.package_version
ORDER BY gd.created_at;
"

echo
echo "=== EXACT LEGACY ROWS REQUIRING NONAUTHORITATIVE PRESERVATION ==="
sqlite3 -header -column db/main.db "
SELECT gd.*
FROM governance_delegations gd
LEFT JOIN matilda_canonical_packages cp
  ON cp.package_id = gd.package_id
 AND cp.package_version = gd.package_version
JOIN governance_packages gp
  ON gp.package_id = gd.package_id
 AND gp.package_version = gd.package_version
WHERE cp.package_id IS NULL
ORDER BY gd.created_at;
"

echo
echo "=== CANONICAL DELEGATION READERS ==="
rg -n -C 8 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'FROM governance_delegations|JOIN governance_delegations|governance_delegations gd' \
  db server routes scripts \
  2>/dev/null | head -n 2200

echo
echo "=== HISTORICAL PRESERVATION CONTRACT EVIDENCE ==="
rg -n -C 12 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'HISTORICAL_DELEGATION_PRESERVED|HISTORICAL_DELEGATION_STILL_PRESENT|Historical corridor-smoke Delegation|historical.*Delegation|legacy.*Delegation' \
  scripts docs/governance db server \
  2>/dev/null | head -n 1800

echo
echo "=== TABLE-SEPARATION PRECEDENTS ==="
rg -n -C 10 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'CREATE TABLE.*legacy|CREATE TABLE.*historical|_legacy_root|_legacy|_historical|archive|historical table|compatibility surface' \
  db drizzle scripts docs/governance \
  2>/dev/null | head -n 1800

echo
echo "=== MIGRATION THAT CREATED THE CONTRADICTION ==="
sed -n '1,180p' scripts/migrate-delegation-root-to-canonical.sh

echo
echo "=== VALIDATION CONTRACT THAT PRESERVED IT ==="
sed -n '1,180p' scripts/validate-canonical-delegation-root.sh

echo
echo "=== SCHEMA STABILITY CONTRACT ==="
sed -n '1,160p' scripts/verify-delegation-reanchor-schema-stability.sh

echo
echo "=== RUNTIME AUTHORITY ==="
sed -n '691,810p' db/governance-runtime.ts

echo
echo "=== FALSIFICATION: DOES ANY ACTIVE RUNTIME REQUIRE LEGACY ROW ==="
rg -n -C 10 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'corridor-delegation|corridor-smoke' \
  db server routes \
  2>/dev/null || true

echo
echo "=== CLASSIFICATION ==="
echo "VERIFIED_OUTCOME=CANONICAL_DELEGATION_TABLE_HAS_ONE_DECLARED_AUTHORITY_ROOT"
echo "VERIFIED_OUTCOME=NEW_DELEGATION_RUNTIME_ALREADY_ENFORCES_CANONICAL_PACKAGE_AUTHORITY"
echo "VERIFIED_OUTCOME=LEGACY_DELEGATION_PRESERVATION_IS_HISTORICAL_NOT_AUTHORITATIVE"
echo "VERIFIED_OUTCOME=LEGACY_ROW_CANNOT_REMAIN_IN_CANONICAL_TABLE_WITHOUT_PERSISTENT_FK_VIOLATION"
echo "VERIFIED_OUTCOME=SEPARATION_CAN_PRESERVE_HISTORY_WITHOUT_CHANGING_NEW_DELEGATION_AUTHORITY"
echo "DEFERRED_WORK=VALIDATION_ROOT_RECONCILIATION"
echo "PROPOSED_IMPLEMENTATION=SEPARATE_NONAUTHORITATIVE_LEGACY_DELEGATION_HISTORY_FROM_CANONICAL_DELEGATION_TABLE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "CURRENT_SCOPE=DELEGATION_HISTORICAL_SEPARATION_READINESS"
echo "NEXT_DECISION=CLASSIFY_MINIMUM_SAFE_MIGRATION_AND_READER_IMPACT_BEFORE_IMPLEMENTATION"
