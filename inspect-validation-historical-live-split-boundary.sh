#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATION HISTORICAL / LIVE SPLIT BOUNDARY ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== VERIFIED CURRENT VALIDATION SCHEMA ==="
sqlite3 -header -column db/main.db "PRAGMA table_info(governance_validation_results);"
sqlite3 -header -column db/main.db "PRAGMA foreign_key_list(governance_validation_results);"

echo
echo "=== VERIFIED HISTORICAL VALIDATION LINEAGE ==="
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
echo "=== CURRENT GOVERNANCE VALIDATION INITIALIZER ==="
rg -n -C 18 \
  'CREATE TABLE IF NOT EXISTS governance_validation_results|CREATE TABLE governance_validation_results' \
  db/governance-runtime.ts

echo
echo "=== CURRENT VALIDATION WRITE IMPLEMENTATION ==="
rg -n -C 35 \
  'function createGovernanceValidationResult|export function createGovernanceValidationResult|createGovernanceValidationResult' \
  db/governance-runtime.ts \
  server/validation \
  server/routes \
  2>/dev/null | head -n 1200

echo
echo "=== VALIDATION ROUTE / ENTRY / CONSUMER SURFACES ==="
find server -maxdepth 4 -type f \
  \( -iname '*validation*' -o -iname '*governance*' \) \
  -print | sort

rg -n -C 12 \
  'createGovernanceValidationResult|validation_result_id|validation_status|governance_validation_results' \
  server \
  2>/dev/null | head -n 1600

echo
echo "=== DOWNSTREAM GATE EXPECTATIONS ==="
sed -n '1,220p' server/gate/production-envelope-gate-entry-point.ts 2>/dev/null || true
sed -n '1,180p' server/gate/production-envelope-gate-consumer.ts 2>/dev/null || true

echo
echo "=== DOWNSTREAM ENVELOPE EXPECTATIONS ==="
sed -n '1,220p' server/envelope/production-envelope-entry-point.ts 2>/dev/null || true
sed -n '1,180p' server/envelope/production-envelope-consumer.ts 2>/dev/null || true

echo
echo "=== CANONICAL DELEGATION LIVE SCHEMA ==="
sqlite3 -header -column db/main.db "PRAGMA table_info(governance_delegations);"
sqlite3 -header -column db/main.db "PRAGMA foreign_key_list(governance_delegations);"

echo
echo "=== CANONICAL PACKAGE LIVE SCHEMA ==="
sqlite3 -header -column db/main.db "PRAGMA table_info(matilda_canonical_packages);"

echo
echo "=== CANONICAL DELEGATION SPECIFICATION: VALIDATION BOUNDARY ==="
rg -n -C 16 \
  'Relationship To Governance Validation|Governance Validation|Validation' \
  docs/governance/CANONICAL_DELEGATION_SPECIFICATION.md \
  | head -n 500

echo
echo "=== HISTORICAL PRESERVATION DOCTRINE ==="
sed -n '1,100p' docs/governance/LINEAGE_PRESERVATION_RULES.md

echo
echo "=== DETERMINE WHETHER DOWNSTREAM TABLES FORCE SAME VALIDATION TABLE IDENTITY ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_list(governance_envelope_gates);"
sqlite3 -header -column db/main.db "PRAGMA foreign_key_list(governance_envelopes);"

rg -n -C 12 \
  'REFERENCES governance_validation_results|FOREIGN KEY.*validation_result_id|validation_result_id.*REFERENCES' \
  db drizzle scripts \
  2>/dev/null | head -n 900

echo
echo "=== CLASSIFICATION ==="
echo "HISTORICAL_VALIDATION_ROW=corridor-validation"
echo "HISTORICAL_VALIDATION_PACKAGE=corridor-smoke@1"
echo "HISTORICAL_VALIDATION_DELEGATION=corridor-delegation"
echo "HISTORICAL_VALIDATION_HAS_GATE_DEPENDENT=YES"
echo "HISTORICAL_VALIDATION_HAS_ENVELOPE_DEPENDENT=YES"
echo "HISTORICAL_REPARENTING_ALLOWED=NO"
echo "NEW_DELEGATION_ROOT=MATILDA_CANONICAL_PACKAGES"
echo "NEW_VALIDATION_MUST_FOLLOW_EXACT_CANONICAL_PACKAGE_VERSION=YES"
echo "NEW_VALIDATION_MUST_FOLLOW_EXPLICIT_DELEGATION=YES"
echo "EXISTING_VALIDATION_TABLE_CAN_SAFELY_SERVE_BOTH_LINEAGES=NOT_YET_ESTABLISHED"
echo "SEPARATE_CANONICAL_VALIDATION_TABLE_REQUIRED=NOT_YET_ESTABLISHED"
echo "DOWNSTREAM_GATE_SPLIT_REQUIRED=NOT_YET_ESTABLISHED"
echo "DOWNSTREAM_ENVELOPE_SPLIT_REQUIRED=NOT_YET_ESTABLISHED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=CLASSIFY_WHETHER_CANONICAL_VALIDATION_REQUIRES_A_PARALLEL_LIVE_PERSISTENCE_CHAIN_OR_A_COMPATIBLE_APPEND_ONLY_EXTENSION_WITHOUT_HISTORICAL_REPARENTING"
