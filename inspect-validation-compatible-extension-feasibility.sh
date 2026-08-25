#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== VALIDATION COMPATIBLE EXTENSION FEASIBILITY ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== CURRENT LIVE VALIDATION / DEPENDENT SCHEMAS ==="
sqlite3 db/main.db ".schema governance_validation_results"
sqlite3 db/main.db ".schema governance_envelope_gates"
sqlite3 db/main.db ".schema governance_envelopes"

echo
echo "=== CURRENT HISTORICAL ROW ==="
sqlite3 -header -column db/main.db "
SELECT *
FROM governance_validation_results
WHERE validation_result_id = 'corridor-validation';
"

echo
echo "=== PACKAGE ROOT COMPATIBILITY ==="
sqlite3 -header -column db/main.db "
SELECT
  v.validation_result_id,
  v.package_id,
  v.package_version,
  CASE WHEN gp.package_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS legacy_package_exists,
  CASE WHEN cp.package_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS canonical_package_exists
FROM governance_validation_results v
LEFT JOIN governance_packages gp
  ON gp.package_id = v.package_id
 AND gp.package_version = v.package_version
LEFT JOIN matilda_canonical_packages cp
  ON cp.package_id = v.package_id
 AND cp.package_version = v.package_version;
"

echo
echo "=== DELEGATION ROOT COMPATIBILITY ==="
sqlite3 -header -column db/main.db "
SELECT
  v.validation_result_id,
  v.delegation_id,
  CASE WHEN ld.delegation_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS legacy_delegation_exists,
  CASE WHEN cd.delegation_id IS NOT NULL THEN 'YES' ELSE 'NO' END AS canonical_delegation_exists
FROM governance_validation_results v
LEFT JOIN governance_delegations_legacy_root ld
  ON ld.delegation_id = v.delegation_id
LEFT JOIN governance_delegations cd
  ON cd.delegation_id = v.delegation_id;
"

echo
echo "=== SQLITE FOREIGN-KEY MODEL LIMITS ==="
echo "A single FOREIGN KEY cannot conditionally target one of two parent tables."
echo "Therefore a dual-root table cannot represent both historical and canonical lineage with one ordinary package FK and one ordinary delegation FK."
echo "Testing whether explicit lineage classification plus guarded runtime validation could preserve both without reparenting."

echo
echo "=== SEARCH FOR EXISTING LINEAGE CLASSIFICATION PATTERN ==="
rg -n -C 10 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'lineage_type|lineage_kind|lineage_source|root_type|root_kind|historical.*canonical|canonical.*historical|legacy.*canonical|canonical.*legacy' \
  db server drizzle scripts docs/governance \
  2>/dev/null | head -n 1400

echo
echo "=== VALIDATION WRITE CALLERS ==="
rg -n -C 14 \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  'createGovernanceValidationResult\(' \
  db server routes scripts \
  2>/dev/null | head -n 1200

echo
echo "=== EXACT PACKAGE / DELEGATION CONSISTENCY GUARDS ==="
rg -n -C 12 \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  'package_id.*delegation|delegation.*package_id|package_version.*delegation|delegation.*package_version|authorization_state.*AUTHORIZED' \
  db/governance-runtime.ts \
  server/validation \
  scripts \
  2>/dev/null | head -n 1400

echo
echo "=== DOWNSTREAM IDENTITY REQUIREMENT ==="
sqlite3 -header -column db/main.db "
SELECT
  v.validation_result_id,
  g.envelope_gate_id,
  e.envelope_id,
  CASE WHEN g.validation_result_id = v.validation_result_id THEN 'PRESERVED' ELSE 'BROKEN' END AS gate_validation_identity,
  CASE WHEN e.validation_result_id = v.validation_result_id THEN 'PRESERVED' ELSE 'BROKEN' END AS envelope_validation_identity
FROM governance_validation_results v
LEFT JOIN governance_envelope_gates g
  ON g.validation_result_id = v.validation_result_id
LEFT JOIN governance_envelopes e
  ON e.validation_result_id = v.validation_result_id;
"

echo
echo "=== FALSIFICATION SEARCH: EXISTING DUAL-ROOT GOVERNANCE PRECEDENT ==="
rg -n -C 12 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'dual.root|two.root|multiple.*root|parallel.*canonical|parallel.*legacy|historical.*foreign key|legacy.*foreign key|canonical.*foreign key|conditional.*foreign key' \
  db server drizzle scripts docs \
  2>/dev/null | head -n 1400

echo
echo "=== CLASSIFICATION ==="
echo "HISTORICAL_ROW_MUST_REMAIN_IDENTIFIABLE=YES"
echo "HISTORICAL_DOWNSTREAM_VALIDATION_IDENTITY_MUST_REMAIN=YES"
echo "HISTORICAL_PACKAGE_REPARENTING_ALLOWED=NO"
echo "HISTORICAL_DELEGATION_REPARENTING_ALLOWED=NO"
echo "NEW_CANONICAL_VALIDATION_REQUIRES_CANONICAL_PACKAGE_ROOT=YES"
echo "NEW_CANONICAL_VALIDATION_REQUIRES_CANONICAL_DELEGATION_ROOT=YES"
echo "SINGLE_ORDINARY_FK_CAN_TARGET_BOTH_ROOTS=NO"
echo "DUAL_ROOT_RUNTIME_GUARD_PATTERN=NOT_YET_ESTABLISHED"
echo "PARALLEL_CANONICAL_VALIDATION_SURFACE=STILL_POSSIBLE"
echo "COMPATIBLE_APPEND_ONLY_EXTENSION=STILL_POSSIBLE_ONLY_IF_AUTHORITY_CAN_BE_ENFORCED_WITHOUT_FALSE_LINEAGE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=WHETHER_DUAL_ROOT_VALIDATION_CAN_PRESERVE_DATABASE_ENFORCED_AUTHORITY_OR_PARALLEL_CANONICAL_PERSISTENCE_IS_REQUIRED"
