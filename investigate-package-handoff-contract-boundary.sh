#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INVESTIGATE PACKAGE HANDOFF CONTRACT BOUNDARY ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=PACKAGE_HANDOFF_CONTRACT"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== REPOSITORY SEARCH: HANDOFF / CANONICAL / APPROVAL / DELEGATION ==="
git grep -n -E \
  'handoff|canonical_approved|matilda_canonical_packages|Delegation|delegation|Approval|approval|MissionIdentity|package_version|package_id' \
  -- \
  'server/**' \
  'db/**' \
  'client/**' \
  'docs/**' \
  2>/dev/null \
  | head -700 || true

echo
echo "=== CANONICAL PACKAGE PERSISTENCE SURFACE ==="
git grep -n -E \
  'matilda_canonical_packages|canonical_approved|package_version|project_id' \
  -- \
  'db/**' \
  'server/**' \
  2>/dev/null \
  | head -500 || true

echo
echo "=== DELEGATION ENTRY / ROUTE / CONSUMER SURFACE ==="
for file in \
  server/routes/governance-delegation-route.ts \
  server/delegation/production-delegation-consumer.ts \
  server/delegation/production-delegation-entry-point.ts \
  db/governance-runtime.ts
do
  echo "--- ${file} ---"
  test -f "$file" && sed -n '1,900p' "$file" || echo "MISSING"
done

echo
echo "=== MISSION READ / MISSION CONTROL SURFACE ==="
for file in \
  db/mission-read-repository.ts \
  client/src/mission-control/missionReadApi.ts \
  client/src/mission-control/MissionControlProvider.tsx \
  client/src/shell/MissionDashboardWorkspace.tsx
do
  echo "--- ${file} ---"
  test -f "$file" && sed -n '1,700p' "$file" || echo "MISSING"
done

echo
echo "=== CURRENT LIVE CANONICAL PACKAGE / DELEGATION STATE ==="
sqlite3 -header -column db/main.db '
SELECT
  package_id,
  package_version,
  project_id,
  status,
  created_at
FROM matilda_canonical_packages
ORDER BY created_at DESC;
'

sqlite3 -header -column db/main.db '
SELECT
  delegation_id,
  project_id,
  package_id,
  package_version,
  authorization_state,
  delegated_by,
  created_at
FROM governance_delegations
ORDER BY created_at DESC;
'

echo
echo "=== INVESTIGATION QUESTIONS ==="
echo "Q1=WHAT_EXACT_ARTIFACT_TRANSITIONS_FROM_APPROVED_CANONICAL_PACKAGE_INTO_HANDOFF_ELIGIBILITY"
echo "Q2=WHICH_LAYER_OWNS_THAT_TRANSITION"
echo "Q3=IS_DELEGATION_PART_OF_THE_HANDOFF_CONTRACT_OR_A_LATER_DISTINCT_AUTHORITY_EVENT"
echo "Q4=WHAT_EXACT_IDENTITY_MUST_BE_PRESERVED_ACROSS_THE_HANDOFF"
echo "Q5=DOES_ANY_CURRENT_RUNTIME_ALREADY_MATERIALIZE_OR_SELECT_THE_HANDOFF_ARTIFACT"
echo "Q6=DOES_MISSION_READ_CONSUME_THE_HANDOFF_CONTRACT_OR_ONLY_CALLER_SUPPLIED_PACKAGE_ID"
echo "Q7=WHAT_IS_MISSING_BEFORE_PROJECT_BOUND_HANDOFF_CAN_BEGIN"

echo
echo "=== CLASSIFICATION ==="
echo "PACKAGE_HANDOFF_CONTRACT_STATUS=INVESTIGATION_ACTIVE"
echo "DELEGATION_CORRIDOR_REOPENED=NO"
echo "MISSION_CONTROL_IMPLEMENTATION_AUTHORIZED=NO"
echo "DOWNSTREAM_VALIDATION_GATE_ENVELOPE_DEFECT_REOPENED=NO"
echo "NEXT_ACTION=CLASSIFY_PACKAGE_HANDOFF_CONTRACT_FROM_REPOSITORY_EVIDENCE"
