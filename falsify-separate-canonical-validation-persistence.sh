#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FALSIFY SEPARATE CANONICAL VALIDATION PERSISTENCE ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== ESTABLISHED BOUNDARY ==="
echo "LEGACY_VALIDATION_READ_LINEAGE_MUST_BE_PRESERVED=YES"
echo "NEW_VALIDATION_REQUIRES_CANONICAL_PACKAGE_AUTHORITY=YES"
echo "NEW_VALIDATION_REQUIRES_CANONICAL_DELEGATION_AUTHORITY=YES"
echo "SEPARATE_CANONICAL_VALIDATION_TABLE=STRUCTURALLY_COMPATIBLE"
echo "ARCHITECTURALLY_SELECTED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== RUNTIME OWNERSHIP ==="
sed -n '1,180p' server/validation/production-validation-consumer.ts
echo
sed -n '811,930p' db/governance-runtime.ts

echo
echo "=== VALIDATION TYPE CONTRACTS ==="
rg -n -C 10 \
  'CreateGovernanceValidationResultInput|CreatedGovernanceValidationResult|GovernanceValidationPersistenceFunction|ProductionValidationConsumerResult' \
  db/governance-runtime.ts server/validation \
  2>/dev/null | head -n 1400

echo
echo "=== ALL PRODUCTION VALIDATION PERSISTENCE CALLERS ==="
rg -n -C 10 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'createGovernanceValidationResult\(|consumeProductionValidationEntryPoint\(' \
  db server routes client/src \
  2>/dev/null | head -n 1800

echo
echo "=== READ SEMANTICS ==="
sed -n '1,140p' db/mission-read-repository.ts

echo
echo "=== ALL VALIDATION READERS / JOINS ==="
rg -n -C 8 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'FROM governance_validation_results|JOIN governance_validation_results|LEFT JOIN governance_validation_results' \
  db server routes client/src \
  2>/dev/null | head -n 2200

echo
echo "=== DOWNSTREAM VALIDATION IDENTITY WRITERS ==="
rg -n -C 12 \
  'createGovernanceEnvelopeGate|createGovernanceEnvelope|validation_result_id' \
  db/governance-runtime.ts server \
  2>/dev/null | head -n 2400

echo
echo "=== DOWNSTREAM SCHEMAS ==="
sqlite3 db/main.db ".schema governance_envelope_gates"
sqlite3 db/main.db ".schema governance_envelopes"

echo
echo "=== CURRENT DOWNSTREAM FOREIGN KEYS ==="
echo "--- governance_envelope_gates ---"
sqlite3 -header -column db/main.db "PRAGMA foreign_key_list(governance_envelope_gates);"
echo "--- governance_envelopes ---"
sqlite3 -header -column db/main.db "PRAGMA foreign_key_list(governance_envelopes);"

echo
echo "=== VALIDATION RESULT ID ASSUMPTION SEARCH ==="
rg -n -C 10 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'validation_result_id.*PRIMARY KEY|validation_result_id.*UNIQUE|validation_result_id.*REFERENCES|WHERE .*validation_result_id|ON .*validation_result_id' \
  db server routes client/src drizzle \
  2>/dev/null | head -n 2600

echo
echo "=== FALSIFICATION QUESTIONS ==="
echo "Q1=DOES_RUNTIME_OWNERSHIP_REQUIRE_ONE_PHYSICAL_VALIDATION_TABLE"
echo "Q2=CAN_EXISTING_READERS_OBSERVE_BOTH_LEGACY_AND_CANONICAL_VALIDATIONS_WITHOUT_FALSE_LINEAGE"
echo "Q3=CAN_VALIDATION_RESULT_ID_REMAIN_GLOBALLY_UNAMBIGUOUS_ACROSS_TWO_PHYSICAL_TABLES"
echo "Q4=CAN_DOWNSTREAM_GATE_AND_ENVELOPE_FOREIGN_KEYS_REFERENCE_BOTH_VALIDATION_ROOTS_WITH_DATABASE_ENFORCEMENT"
echo "Q5=WOULD_SEPARATE_CANONICAL_VALIDATION_PERSISTENCE_FORCE_DOWNSTREAM_SCHEMA_RECONCILIATION_BEFORE_CANONICAL_VALIDATION_CAN_PARTICIPATE_IN_THE_PIPELINE"
echo "Q6=DOES_ANY_REPOSITORY_EVIDENCE_ESTABLISH_A_DIFFERENT_AUTHORITY_OR_OWNERSHIP_MODEL"

echo
echo "=== CURRENT CLASSIFICATION ==="
echo "SEPARATE_CANONICAL_VALIDATION_SURFACE=FALSIFICATION_IN_PROGRESS"
echo "RUNTIME_OWNERSHIP_CHANGE_AUTHORIZED=NO"
echo "READER_SEMANTICS_CHANGE_AUTHORIZED=NO"
echo "DOWNSTREAM_GATE_MIGRATION_AUTHORIZED=NO"
echo "DOWNSTREAM_ENVELOPE_MIGRATION_AUTHORIZED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=CLASSIFY_WHETHER_SEPARATE_CANONICAL_VALIDATION_IS_A_TRUE_ISOLATED_VALIDATION_SOLUTION_OR_MERELY_DEFERS_THE_DUAL_ROOT_PROBLEM_TO_DOWNSTREAM_CONSUMERS"
