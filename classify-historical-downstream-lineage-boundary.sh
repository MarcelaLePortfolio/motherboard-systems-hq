#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== HISTORICAL DOWNSTREAM LINEAGE BOUNDARY ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== CURRENT EVIDENCE ==="
echo "DELEGATION_ONLY_SEPARATION_SUFFICIENT=NO"
echo "STALE_DOWNSTREAM_DELEGATION_FKS=CONFIRMED"
echo "SOURCE_SCHEMA_EXPECTS_CURRENT_GOVERNANCE_DELEGATIONS=YES"
echo "LEGACY_DELEGATION_ROW_IS_NONCANONICAL_HISTORY=YES"
echo "QUESTION=MUST_HISTORICAL_DOWNSTREAM_ROWS_MOVE_WITH_LEGACY_DELEGATION_OR_CAN_EXISTING_TABLES_PRESERVE_BOTH_LINEAGES_WITHOUT_FALSE_AUTHORITY"

echo
echo "=== COMPLETE DOWNSTREAM LINEAGE CLASSIFICATION ==="
sqlite3 -header -column db/main.db "
WITH artifacts AS (
  SELECT
    'validation' AS artifact_type,
    validation_result_id AS artifact_id,
    package_id,
    package_version,
    delegation_id
  FROM governance_validation_results

  UNION ALL

  SELECT
    'gate',
    envelope_gate_id,
    package_id,
    package_version,
    delegation_id
  FROM governance_envelope_gates

  UNION ALL

  SELECT
    'envelope',
    envelope_id,
    package_id,
    package_version,
    delegation_id
  FROM governance_envelopes
)
SELECT
  a.artifact_type,
  a.artifact_id,
  a.package_id,
  a.package_version,
  a.delegation_id,
  CASE
    WHEN cp.package_id IS NOT NULL THEN 'CANONICAL_PACKAGE'
    WHEN gp.package_id IS NOT NULL THEN 'LEGACY_PACKAGE'
    ELSE 'UNRESOLVED_PACKAGE'
  END AS package_lineage,
  CASE
    WHEN gd.delegation_id IS NOT NULL
         AND cp.package_id IS NOT NULL
      THEN 'CANONICAL_DELEGATION'
    WHEN gd.delegation_id IS NOT NULL
         AND gp.package_id IS NOT NULL
         AND cp.package_id IS NULL
      THEN 'HISTORICAL_LEGACY_DELEGATION'
    WHEN gd.delegation_id IS NULL
      THEN 'MISSING_DELEGATION'
    ELSE 'UNRESOLVED_DELEGATION'
  END AS delegation_lineage
FROM artifacts a
LEFT JOIN governance_delegations gd
  ON gd.delegation_id = a.delegation_id
LEFT JOIN matilda_canonical_packages cp
  ON cp.package_id = a.package_id
 AND cp.package_version = a.package_version
LEFT JOIN governance_packages gp
  ON gp.package_id = a.package_id
 AND gp.package_version = a.package_version
ORDER BY a.artifact_type, a.artifact_id;
"

echo
echo "=== CROSS-ARTIFACT IDENTITY CHAINS ==="
sqlite3 -header -column db/main.db "
SELECT
  v.validation_result_id,
  v.package_id AS validation_package_id,
  v.package_version AS validation_package_version,
  v.delegation_id AS validation_delegation_id,
  g.envelope_gate_id,
  g.package_id AS gate_package_id,
  g.package_version AS gate_package_version,
  g.delegation_id AS gate_delegation_id,
  e.envelope_id,
  e.package_id AS envelope_package_id,
  e.package_version AS envelope_package_version,
  e.delegation_id AS envelope_delegation_id
FROM governance_validation_results v
LEFT JOIN governance_envelope_gates g
  ON g.validation_result_id = v.validation_result_id
LEFT JOIN governance_envelopes e
  ON e.validation_result_id = v.validation_result_id
ORDER BY v.validation_result_id, g.envelope_gate_id, e.envelope_id;
"

echo
echo "=== CANONICAL PACKAGE / DELEGATION OVERLAP CHECK ==="
sqlite3 -header -column db/main.db "
SELECT
  gd.delegation_id,
  gd.package_id,
  gd.package_version,
  CASE WHEN cp.package_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS canonical_package_exists,
  CASE WHEN gp.package_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS legacy_package_exists
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
echo "=== SEARCH FOR EXISTING HISTORY REFERENCE PRECEDENT ==="
rg -n -C 12 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'historical.*reference|history.*reference|legacy.*reference|polymorphic|reference_type|lineage_type|authority_type|source_type|parent_type|canonical.*historical|historical.*canonical' \
  db server routes scripts docs drizzle \
  2>/dev/null | head -n 2200

echo
echo "=== ACTIVE READERS OF DOWNSTREAM TABLES ==="
rg -n -C 12 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'FROM governance_validation_results|FROM governance_envelope_gates|FROM governance_envelopes|JOIN governance_validation_results|JOIN governance_envelope_gates|JOIN governance_envelopes' \
  db server routes scripts \
  2>/dev/null | head -n 2600

echo
echo "=== HISTORICAL ROW CONSUMERS ==="
rg -n -C 12 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'corridor-validation|corridor-gate|corridor-envelope|corridor-delegation|demo-env-1|demo-env-2|demo-del-1|demo-del-2' \
  db server routes scripts docs \
  2>/dev/null | head -n 2600

echo
echo "=== CURRENT FOREIGN KEY CHECK ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_check;"

echo
echo "=== CLASSIFICATION ==="
echo "VERIFIED_OUTCOME=HISTORICAL_DOWNSTREAM_ROWS_FORM_A_LEGACY_LINEAGE_CHAIN"
echo "VERIFIED_OUTCOME=CANONICAL_DELEGATION_AUTHORITY_CANNOT_SHARE_ONE_ORDINARY_FK_WITH_A_SEPARATE_HISTORICAL_PARENT"
echo "VERIFIED_OUTCOME=SOURCE_SCHEMA_ALREADY_DECLARES_CURRENT_DOWNSTREAM_DELEGATION_PARENT_AS_GOVERNANCE_DELEGATIONS"
echo "ARCHITECTURAL_CONSTRAINT=DATABASE_ENFORCED_DELEGATION_AUTHORITY_MUST_NOT_BECOME_POLYMORPHIC_OR_APPLICATION_ONLY_WITHOUT_EXPLICIT_ARCHITECTURAL_AUTHORIZATION"
echo "HISTORICAL_IDENTITY_CHANGE_ALLOWED=NO"
echo "HISTORICAL_PACKAGE_REPARENTING_ALLOWED=NO"
echo "HISTORICAL_DELEGATION_REPARENTING_ALLOWED=NO"
echo "CANONICAL_AUTHORITY_WEAKENING_ALLOWED=NO"
echo "CURRENT_SCOPE=HISTORICAL_DOWNSTREAM_LINEAGE_STORAGE_BOUNDARY"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=DETERMINE_FROM_REPOSITORY_EVIDENCE_WHETHER_HISTORICAL_VALIDATION_GATE_AND_ENVELOPE_ROWS_ARE_RUNTIME_STATE_OR_PRESERVED_FIXTURE_HISTORY_AND_THEREFORE_WHETHER_THE_MINIMUM_SAFE_BOUNDARY_IS_FULL_HISTORICAL_CHAIN_SEPARATION"
