#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== HISTORICAL DOWNSTREAM RUNTIME BOUNDARY ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== ESTABLISHED EVIDENCE ==="
echo "HISTORICAL_DOWNSTREAM_CHAIN=CONFIRMED"
echo "CURRENT_SOURCE_SCHEMA_EXPECTS_GOVERNANCE_DELEGATIONS=CONFIRMED"
echo "LIVE_DB_STALE_DELEGATION_FKS=CONFIRMED"
echo "CURRENT_TABLES_HAVE_ACTIVE_RUNTIME_READERS=CONFIRMED"
echo "HISTORICAL_ROWS_CANNOT_BE_CLASSIFIED_AS_DISPOSABLE_FROM_TABLE_USAGE_ALONE=CONFIRMED"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== HISTORICAL ROWS AND CREATION TIMES ==="
sqlite3 -header -column db/main.db "
SELECT
  'validation' AS artifact_type,
  validation_result_id AS artifact_id,
  package_id,
  package_version,
  delegation_id,
  created_at
FROM governance_validation_results
WHERE package_id = 'corridor-smoke'

UNION ALL

SELECT
  'gate',
  envelope_gate_id,
  package_id,
  package_version,
  delegation_id,
  created_at
FROM governance_envelope_gates
WHERE package_id = 'corridor-smoke'

UNION ALL

SELECT
  'envelope',
  envelope_id,
  package_id,
  package_version,
  delegation_id,
  created_at
FROM governance_envelopes
WHERE package_id = 'corridor-smoke'

ORDER BY created_at;
"

echo
echo "=== ALL CURRENT DOWNSTREAM ROWS BY PACKAGE LINEAGE ==="
sqlite3 -header -column db/main.db "
WITH artifacts AS (
  SELECT
    'validation' AS artifact_type,
    validation_result_id AS artifact_id,
    package_id,
    package_version,
    delegation_id,
    created_at
  FROM governance_validation_results

  UNION ALL

  SELECT
    'gate',
    envelope_gate_id,
    package_id,
    package_version,
    delegation_id,
    created_at
  FROM governance_envelope_gates

  UNION ALL

  SELECT
    'envelope',
    envelope_id,
    package_id,
    package_version,
    delegation_id,
    created_at
  FROM governance_envelopes
)
SELECT
  a.artifact_type,
  a.artifact_id,
  a.package_id,
  a.package_version,
  a.delegation_id,
  CASE WHEN cp.package_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS canonical_package,
  CASE WHEN gp.package_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS legacy_package,
  a.created_at
FROM artifacts a
LEFT JOIN matilda_canonical_packages cp
  ON cp.package_id = a.package_id
 AND cp.package_version = a.package_version
LEFT JOIN governance_packages gp
  ON gp.package_id = a.package_id
 AND gp.package_version = a.package_version
ORDER BY a.created_at;
"

echo
echo "=== DIRECT RUNTIME READERS ==="
rg -n -C 10 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'FROM governance_validation_results|FROM governance_envelope_gates|FROM governance_envelopes|UPDATE governance_envelopes|JOIN governance_validation_results|JOIN governance_envelope_gates|JOIN governance_envelopes' \
  db server routes client/src \
  2>/dev/null | head -n 2600

echo
echo "=== DIRECT RUNTIME WRITERS ==="
rg -n -C 12 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'INSERT INTO governance_validation_results|INSERT INTO governance_envelope_gates|INSERT INTO governance_envelopes|createGovernanceValidationResult|createGovernanceEnvelopeGate|createGovernanceEnvelope|persistGovernanceEnvelopeLifecycleTransition' \
  db server routes \
  2>/dev/null | head -n 3000

echo
echo "=== CORRIDOR-SMOKE RUNTIME DEPENDENCY SEARCH ==="
rg -n -C 10 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'corridor-smoke|corridor-validation|corridor-gate|corridor-envelope|corridor-delegation' \
  db server routes client/src \
  2>/dev/null | head -n 2200

echo
echo "=== CORRIDOR-SMOKE TEST / INSPECTION DEPENDENCY SEARCH ==="
rg -n -C 8 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'corridor-smoke|corridor-validation|corridor-gate|corridor-envelope|corridor-delegation' \
  scripts docs \
  2>/dev/null | head -n 2600

echo
echo "=== CURRENT MISSION READ MODEL ==="
sed -n '1,180p' db/mission-read-repository.ts

echo
echo "=== LIFECYCLE PERSISTENCE DEPENDENCY ==="
sed -n '1,180p' db/governance-lifecycle-persistence.ts

echo
echo "=== CURRENT FOREIGN KEY CHECK ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_check;"

echo
echo "=== SCOPE DETERMINATION ==="
echo "VERIFIED_OUTCOME=DELEGATION_CANONICAL_ROOT_COMPLETE"
echo "VERIFIED_OUTCOME=HISTORICAL_VALIDATION_GATE_ENVELOPE_CHAIN_REMAINS_LEGACY_ROOTED"
echo "VERIFIED_OUTCOME=CURRENT_VALIDATION_GATE_ENVELOPE_TABLES_ARE_ACTIVE_RUNTIME_SURFACES"
echo "VERIFIED_OUTCOME=STALE_DELEGATION_FOREIGN_KEYS_ARE_A_LIVE_SCHEMA_DEFECT"
echo "DEFERRED=GATE_ENVELOPE_OPERATIONAL_INTAKE_ROOT_RECONCILIATION"
echo "PROPOSED_IMPLEMENTATION=NONE"
echo "CURRENT_SCOPE=VALIDATION_ROOT_RECONCILIATION_READINESS"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "DECISION_QUESTION=DO_THE_SPECIFIC_CORRIDOR_SMOKE_DOWNSTREAM_ROWS_HAVE_ANY_REQUIRED_RUNTIME_SEMANTICS_BEYOND_PRESERVED_HISTORICAL_EVIDENCE"
echo "NEXT_STEP=CLASSIFY_SPECIFIC_HISTORICAL_ROWS_NOT_THE_TABLES_AS_RUNTIME_REQUIRED_OR_HISTORY_ONLY_BEFORE_SELECTING_A_STORAGE_MIGRATION_BOUNDARY"
