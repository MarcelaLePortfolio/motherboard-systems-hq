#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT LIVE DELEGATION MIGRATION READINESS ==="
echo "HEAD=$(git rev-parse --short=8 HEAD)"
echo "BRANCH=$(git branch --show-current)"
echo

echo "=== LIVE DELEGATION TABLE ==="
sqlite3 db/main.db '.schema governance_delegations'

echo
echo "=== LIVE DELEGATION ROWS ==="
sqlite3 -header -column db/main.db '
SELECT delegation_id, package_id, package_version, authorization_state, delegated_by, created_at
FROM governance_delegations
ORDER BY created_at, delegation_id;
'

echo
echo "=== CANONICAL ROOT MATCHES FOR LIVE DELEGATIONS ==="
sqlite3 -header -column db/main.db '
SELECT
  d.delegation_id,
  d.package_id,
  d.package_version,
  c.project_id,
  c.status AS canonical_status,
  CASE WHEN c.package_id IS NULL THEN "NO" ELSE "YES" END AS canonical_root_exists
FROM governance_delegations AS d
LEFT JOIN matilda_canonical_packages AS c
  ON c.package_id = d.package_id
 AND c.package_version = d.package_version
ORDER BY d.created_at, d.delegation_id;
'

echo
echo "=== DOWNSTREAM LIVE REFERENCES ==="
for table in governance_validation_results governance_envelope_gates governance_envelopes; do
  echo "--- ${table} ---"
  sqlite3 -header -column db/main.db "PRAGMA foreign_key_list(${table});"
done

echo
echo "=== MIGRATION FILE ==="
cat drizzle/0010_project_scoped_delegation_reference.sql

echo
echo "=== CLASSIFICATION ==="
echo "CODE_COMPLETE_VALIDATED=YES"
echo "LIVE_DATABASE_MIGRATION_APPLIED=NO"
echo "LIVE_MIGRATION_AUTHORIZED=NO"
echo "KNOWN_DOWNSTREAM_LEGACY_ROOT_DEFECT=STILL_SEPARATE"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=CLASSIFY_LIVE_DATA_AND_LINEAGE_COMPATIBILITY_BEFORE_AUTHORIZATION"
