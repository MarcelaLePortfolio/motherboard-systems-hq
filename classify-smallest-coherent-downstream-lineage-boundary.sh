#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY SMALLEST COHERENT DOWNSTREAM LINEAGE BOUNDARY ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== VERIFIED PRIOR CLOSURE ==="
echo "VALIDATION_ONLY_RECONCILIATION=FALSIFIED_AS_ISOLATED_SOLUTION"
echo "SEPARATE_CANONICAL_VALIDATION_TABLE=NOT_SELECTED"
echo "REASON=GATE_AND_ENVELOPE_REMAIN_BOUND_TO_CURRENT_VALIDATION_SURFACE"
echo "HISTORICAL_LEGACY_LINEAGE_MUST_REMAIN_TRUTHFUL=YES"
echo "NEW_CANONICAL_LINEAGE_MUST_BE_DATABASE_ENFORCEABLE=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CURRENT DOWNSTREAM TABLE CONTRACTS ==="
for table in \
  governance_validation_results \
  governance_envelope_gates \
  governance_envelopes
do
  echo
  echo "--- $table schema ---"
  sqlite3 db/main.db ".schema $table"
  echo "--- $table foreign keys ---"
  sqlite3 -header -column db/main.db "PRAGMA foreign_key_list($table);"
done

echo
echo "=== CURRENT HISTORICAL LINEAGE ==="
sqlite3 -header -column db/main.db "
SELECT
  p.package_id,
  p.package_version,
  d.delegation_id,
  v.validation_result_id,
  g.envelope_gate_id,
  e.envelope_id,
  e.lifecycle_state
FROM governance_packages p
LEFT JOIN governance_delegations d
  ON d.package_id = p.package_id
 AND d.package_version = p.package_version
LEFT JOIN governance_validation_results v
  ON v.package_id = p.package_id
 AND v.package_version = p.package_version
LEFT JOIN governance_envelope_gates g
  ON g.package_id = p.package_id
 AND g.package_version = p.package_version
LEFT JOIN governance_envelopes e
  ON e.package_id = p.package_id
 AND e.package_version = p.package_version
WHERE p.package_id = 'corridor-smoke'
  AND p.package_version = 1;
"

echo
echo "=== SOURCE-DECLARED GOVERNANCE ROOTS ==="
sed -n '233,330p' db/governance-runtime.ts

echo
echo "=== WRITE PATH DEPENDENCY CHAIN ==="
rg -n -C 14 \
  'createGovernanceValidationResult|createGovernanceEnvelopeGate|createGovernanceEnvelope|INSERT INTO governance_validation_results|INSERT INTO governance_envelope_gates|INSERT INTO governance_envelopes' \
  db/governance-runtime.ts server/validation server/gate server/envelope \
  2>/dev/null | head -n 3200

echo
echo "=== READ PATH DEPENDENCY CHAIN ==="
sed -n '18,95p' db/mission-read-repository.ts

echo
echo "=== LIFECYCLE MUTATION DEPENDENCY ==="
rg -n -C 14 \
  'governance_envelopes|envelope_id|lifecycle_state|ASSIGNED|ENVELOPE_CREATED' \
  db/governance-lifecycle-persistence.ts db/operational-intake-runtime.ts server/lifecycle server/operational \
  2>/dev/null | head -n 3000

echo
echo "=== HISTORICAL PRESERVATION DOCTRINE ==="
rg -n -C 12 \
  'corridor-smoke|historical.*lineage|not migrated|not.*reparented|not.*Canonical|historical data|preserved' \
  docs/governance \
  2>/dev/null | head -n 2400

echo
echo "=== BOUNDARY CANDIDATES ==="
echo "CANDIDATE_A=VALIDATION_ONLY"
echo "CANDIDATE_B=VALIDATION_PLUS_ENVELOPE_GATE"
echo "CANDIDATE_C=VALIDATION_PLUS_ENVELOPE_GATE_PLUS_ENVELOPE"
echo "CANDIDATE_D=VALIDATION_PLUS_GATE_PLUS_ENVELOPE_PLUS_OPERATIONAL_INTAKE"

echo
echo "=== FALSIFICATION A: VALIDATION ONLY ==="
echo "A_DATABASE_ENFORCED_CANONICAL_CONTINUITY_TO_GATE=NO"
echo "A_RESULT=REJECTED"

echo
echo "=== FALSIFICATION B: VALIDATION + GATE ==="
echo "B_ENVELOPE_STILL_REFERENCES_VALIDATION_RESULT_ID=YES"
echo "B_ENVELOPE_STILL_REFERENCES_ENVELOPE_GATE_ID=YES"
echo "B_ENVELOPE_PACKAGE_ROOT_CURRENTLY_LEGACY=YES"
echo "B_ENVELOPE_DELEGATION_ROOT_CURRENTLY_STALE_LEGACY=YES"
echo "B_DATABASE_ENFORCED_CANONICAL_CONTINUITY_TO_ENVELOPE=NO"
echo "B_RESULT=REJECTED_IF_ENVELOPE_MUST_REMAIN_REACHABLE"

echo
echo "=== FALSIFICATION C: VALIDATION + GATE + ENVELOPE ==="
echo "C_COVERS_PACKAGE_DELEGATION_VALIDATION_GATE_ENVELOPE_LINEAGE=YES"
echo "C_PRESERVES_PRE_ASSIGNMENT_MISSION_READ_STAGE_SURFACE=YES"
echo "C_REQUIRES_OPERATIONAL_INTAKE_CHANGE_FOR_PRE_ASSIGNMENT_READ=NO"
echo "C_TOUCHES_ASSIGNMENT_OR_EXECUTION_AUTHORITY=NO"
echo "C_RESULT=CANDIDATE_MINIMUM"

echo
echo "=== FALSIFICATION D: INCLUDE OPERATIONAL INTAKE ==="
echo "D_REQUIRED_TO_ESTABLISH_CANONICAL_VALIDATION_TO_ENVELOPE_LINEAGE=NO"
echo "D_CROSSES_INTO_ASSIGNMENT_LIFECYCLE_BOUNDARY=YES"
echo "D_RESULT=TOO_BROAD_FOR_CURRENT_QUESTION"

echo
echo "=== CURRENT FOREIGN KEY CHECK ==="
sqlite3 -header -column db/main.db "PRAGMA foreign_key_check;"

echo
echo "=== CLASSIFICATION ==="
echo "SMALLEST_COHERENT_DOWNSTREAM_LINEAGE_BOUNDARY=VALIDATION_PLUS_ENVELOPE_GATE_PLUS_ENVELOPE"
echo "BOUNDARY_INCLUDES=GOVERNANCE_VALIDATION_RESULTS"
echo "BOUNDARY_INCLUDES=GOVERNANCE_ENVELOPE_GATES"
echo "BOUNDARY_INCLUDES=GOVERNANCE_ENVELOPES"
echo "BOUNDARY_EXCLUDES=OPERATIONAL_INTAKE"
echo "BOUNDARY_EXCLUDES=ASSIGNMENT"
echo "BOUNDARY_EXCLUDES=ROUTING"
echo "BOUNDARY_EXCLUDES=EXECUTION"
echo "HISTORICAL_CORRIDOR_SMOKE_MUTATION_AUTHORIZED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_STEP=RE_CENTER_ON_AUTHORITATIVE_MISSION_PACKAGE_HANDOFF_AND_DETERMINE_WHETHER_THIS_DOWNSTREAM_SCHEMA_RECONCILIATION_IS_ACTUALLY_REQUIRED_FOR_OPERATIONAL_PACKAGE_AUTHORITY_OR_SHOULD_BE_SEPARATELY_DEFERRED"
