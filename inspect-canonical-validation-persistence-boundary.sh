#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CANONICAL VALIDATION PERSISTENCE BOUNDARY ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== HISTORICAL PRESERVATION CONTRACT ==="
sed -n '1,120p' docs/governance/PRODUCTION_DELEGATION_PACKAGE_ROOT_RECONCILIATION_CLOSURE_2026-08-23.md

echo
echo "=== CURRENT VALIDATION SCHEMA AND INITIALIZER ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_list(governance_validation_results);"
sed -n '240,285p' db/governance-runtime.ts

echo
echo "=== VALIDATION RUNTIME TYPES AND WRITE PATH ==="
rg -n -C 10 \
  'CreateGovernanceValidationResultInput|CreatedGovernanceValidationResult|createGovernanceValidationResult' \
  db/governance-runtime.ts \
  server/validation \
  server/routes \
  2>/dev/null | head -n 900

echo
echo "=== VALIDATION READERS / DOWNSTREAM CONSUMERS ==="
rg -n -C 8 \
  'governance_validation_results|validation_result_id' \
  db server routes client scripts \
  --glob '!*.test.ts' \
  --glob '!*.spec.ts' \
  --glob '!*.bak' \
  2>/dev/null | head -n 1200

echo
echo "=== SEARCH FOR PARALLEL HISTORICAL/LIVE PERSISTENCE PATTERNS ==="
rg -n -C 8 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'historical.*table|legacy.*table|canonical.*table|production.*table|_legacy|legacy_root|historical.*preserv|preserv.*historical' \
  db drizzle server scripts docs \
  2>/dev/null | head -n 1200

echo
echo "=== FALSIFICATION: IS IN-PLACE VALIDATION REBUILD ACTUALLY REQUIRED? ==="
rg -n -C 8 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'ALTER TABLE governance_validation_results|RENAME TO governance_validation|migrate.*validation|validation.*migration|canonical.*validation.*table|validation.*canonical.*table|new.*validation.*table|parallel.*validation' \
  db drizzle server scripts docs \
  2>/dev/null | head -n 1000

echo
echo "=== LIVE DATA PRESERVATION CHECK ==="
sqlite3 -header -column db/main.db "
SELECT
  v.validation_result_id,
  v.package_id,
  v.package_version,
  v.delegation_id,
  COUNT(DISTINCT g.envelope_gate_id) AS gate_dependents,
  COUNT(DISTINCT e.envelope_id) AS envelope_dependents
FROM governance_validation_results v
LEFT JOIN governance_envelope_gates g
  ON g.validation_result_id = v.validation_result_id
LEFT JOIN governance_envelopes e
  ON e.validation_result_id = v.validation_result_id
GROUP BY
  v.validation_result_id,
  v.package_id,
  v.package_version,
  v.delegation_id;
"

echo
echo "=== CLASSIFICATION ==="
echo "VERIFIED_HISTORICAL_LINEAGE=CORRIDOR_SMOKE"
echo "HISTORICAL_REPARENTING_ALLOWED=NO"
echo "HISTORICAL_DOWNSTREAM_DEPENDENTS_PRESENT=YES"
echo "CURRENT_VALIDATION_PACKAGE_ROOT=LEGACY_GOVERNANCE_PACKAGES"
echo "CURRENT_LIVE_VALIDATION_DELEGATION_FK=LEGACY_RENAMED_TABLE"
echo "FRESH_RUNTIME_DELEGATION_FK=GOVERNANCE_DELEGATIONS"
echo "CANONICAL_VALIDATION_PERSISTENCE_SURFACE=NOT_YET_ESTABLISHED"
echo "IN_PLACE_REBUILD_REQUIRED=NOT_YET_ESTABLISHED"
echo "PARALLEL_CANONICAL_VALIDATION_SURFACE_REQUIRED=NOT_YET_ESTABLISHED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "DECISION_QUESTION=WHAT_IS_THE_SMALLEST_PERSISTENCE_BOUNDARY_THAT_ALLOWS_NEW_CANONICAL_VALIDATION_WITHOUT_REINTERPRETING_OR_REPARENTING_HISTORICAL_CORRIDOR_SMOKE"
