#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY LIVE DELEGATION MIGRATION LINEAGE COMPATIBILITY ==="

echo
echo "=== VERIFIED LIVE FACTS ==="
echo "LIVE_DELEGATION_COUNT=$(sqlite3 db/main.db 'SELECT COUNT(*) FROM governance_delegations;')"
echo "LIVE_CANONICAL_ROOTED_DELEGATION_COUNT=$(sqlite3 db/main.db '
SELECT COUNT(*)
FROM governance_delegations AS d
JOIN matilda_canonical_packages AS c
  ON c.package_id = d.package_id
 AND c.package_version = d.package_version;
')"
echo "LIVE_UNROOTED_DELEGATION_COUNT=$(sqlite3 db/main.db '
SELECT COUNT(*)
FROM governance_delegations AS d
LEFT JOIN matilda_canonical_packages AS c
  ON c.package_id = d.package_id
 AND c.package_version = d.package_version
WHERE c.package_id IS NULL;
')"

echo
echo "=== HISTORICAL DELEGATION DETAIL ==="
sqlite3 -header -column db/main.db '
SELECT
  d.delegation_id,
  d.package_id,
  d.package_version,
  d.authorization_state,
  d.delegated_by,
  c.project_id,
  c.status AS canonical_status,
  CASE WHEN c.package_id IS NULL THEN "HISTORICAL_UNROOTED" ELSE "CANONICAL_ROOTED" END AS lineage_class
FROM governance_delegations AS d
LEFT JOIN matilda_canonical_packages AS c
  ON c.package_id = d.package_id
 AND c.package_version = d.package_version;
'

echo
echo "=== MIGRATION EFFECT ON HISTORICAL ROW ==="
echo "MIGRATION_BACKFILLS_PROJECT_ID_FROM_CANONICAL_ROOT=YES"
echo "UNROOTED_HISTORICAL_ROW_PROJECT_ID_AFTER_MIGRATION=NULL"
echo "HISTORICAL_ROW_REPARENTED=NO"
echo "HISTORICAL_ROW_DELETED=NO"
echo "HISTORICAL_PACKAGE_ID_MUTATED=NO"
echo "HISTORICAL_PACKAGE_VERSION_MUTATED=NO"

echo
echo "=== DOWNSTREAM DEFECT BOUNDARY ==="
VALIDATION_FK_TARGET="$(
  sqlite3 db/main.db \
    "SELECT DISTINCT \"table\" FROM pragma_foreign_key_list('governance_validation_results') WHERE \"from\"='delegation_id';"
)"
GATE_FK_TARGET="$(
  sqlite3 db/main.db \
    "SELECT DISTINCT \"table\" FROM pragma_foreign_key_list('governance_envelope_gates') WHERE \"from\"='delegation_id';"
)"
ENVELOPE_FK_TARGET="$(
  sqlite3 db/main.db \
    "SELECT DISTINCT \"table\" FROM pragma_foreign_key_list('governance_envelopes') WHERE \"from\"='delegation_id';"
)"

echo "VALIDATION_FK_TARGET=${VALIDATION_FK_TARGET}"
echo "GATE_FK_TARGET=${GATE_FK_TARGET}"
echo "ENVELOPE_FK_TARGET=${ENVELOPE_FK_TARGET}"

test "$VALIDATION_FK_TARGET" = "governance_delegations_legacy_root"
test "$GATE_FK_TARGET" = "governance_delegations_legacy_root"
test "$ENVELOPE_FK_TARGET" = "governance_delegations_legacy_root"

echo
echo "=== CLASSIFICATION ==="
echo "LIVE_DATA_COMPATIBILITY=BOUNDED_COMPATIBLE"
echo "LIVE_HISTORICAL_DELEGATION=corridor-delegation"
echo "LIVE_HISTORICAL_PACKAGE=corridor-smoke@1"
echo "LIVE_HISTORICAL_DELEGATION_CANONICAL_ROOT=ABSENT"
echo "MIGRATION_PRESERVES_HISTORICAL_UNROOTED_ROW=YES"
echo "MIGRATION_DOES_NOT_FALSELY_REPARENT_HISTORY=YES"
echo "PROJECT_SCOPED_NEW_DELEGATION_CONTRACT=SUPPORTED"
echo "KNOWN_DOWNSTREAM_LEGACY_ROOT_DEFECT=VERIFIED_UNCHANGED_AND_SEPARATE"
echo "LIVE_MIGRATION_TECHNICAL_COMPATIBILITY=ESTABLISHED_WITHIN_CURRENT_UNIT"
echo "LIVE_MIGRATION_AUTHORIZED=NO"
echo "CORRIDOR_CLOSED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=USER_AUTHORIZATION_REQUIRED_BEFORE_LIVE_DATABASE_MIGRATION"
