#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== OPERATIONAL PACKAGE AUTHORITY GAP ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== VERIFIED CURRENT READ SELECTION ==="
rg -n -C 12 \
  'ACTIVE_PACKAGE_ID|loadMission\(|package_id = \?|SELECT package_id FROM governance_packages LIMIT 1' \
  client/src/shell/MissionDashboardWorkspace.tsx \
  db/mission-read-repository.ts \
  db/mission-read-repository.integration.test.ts \
  db/mission-read-model.integration.test.ts \
  2>/dev/null

echo
echo "=== SEARCH FOR AUTHORITATIVE PACKAGE NOMINATION PERSISTENCE ==="
rg -n -C 16 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'active_package|active_package_id|operational_package|mission_package|mission_identity|package_nomination|nominated_package|selected_package|authoritative_package|current_package|package_handoff|handoff.*package|package.*handoff' \
  db server drizzle client/src docs/governance \
  2>/dev/null | head -n 4200

echo
echo "=== SEARCH PERSISTED PROJECT/PACKAGE BINDINGS ==="
sqlite3 -header -column db/main.db "
SELECT
  package_id,
  package_version,
  project_id,
  conversation_id,
  status,
  created_at
FROM matilda_canonical_packages
ORDER BY created_at;
"

echo
echo "=== GOVERNANCE PACKAGE PROJECT BINDINGS ==="
sqlite3 -header -column db/main.db "
SELECT
  package_id,
  package_version,
  project_id,
  conversation_id,
  requested_outcome,
  created_at
FROM governance_packages
ORDER BY created_at;
"

echo
echo "=== DELEGATION SEMANTICS ==="
rg -n -C 20 \
  'createGovernanceDelegation|authorization_state|authorization_timestamp|delegated_by|governance_delegations' \
  db/governance-runtime.ts \
  server \
  scripts \
  --glob '!*.bak' \
  2>/dev/null | head -n 3000

echo
echo "=== FALSIFICATION TEST ==="
echo "TEST=SEARCH_FOR_EXISTING_PERSISTED_AUTHORITY_THAT_SELECTS_EXACT_PROJECT_PACKAGE_VERSION_FOR_MISSION_CONTROL"
echo "REJECT_NEW_AUTHORITY_CONTRACT_IF_EXISTING_PERSISTED_AUTHORITY_ALREADY_PERFORMS_EXACT_NOMINATION"

echo
echo "=== CURRENT EVIDENCE CLASSIFICATION ==="
echo "VERIFIED_OUTCOME=MISSION_READ_REPOSITORY_REQUIRES_CALLER_SUPPLIED_PACKAGE_ID"
echo "VERIFIED_OUTCOME=MISSION_READ_MODEL_PRESERVES_PACKAGE_VERSION_AND_PROJECT_ID_AFTER_PACKAGE_SELECTION"
echo "VERIFIED_OUTCOME=MISSION_DASHBOARD_CURRENTLY_LOADS_A_PRESELECTED_ACTIVE_PACKAGE_ID"
echo "VERIFIED_OUTCOME=DELEGATION_AUTHORIZATION_DRIVES_STAGE_PROGRESSION_AFTER_PACKAGE_SELECTION"
echo "NOT_YET_ESTABLISHED=DELEGATION_AS_OPERATIONAL_PACKAGE_NOMINATION_AUTHORITY"
echo "NOT_YET_ESTABLISHED=CANONICAL_APPROVAL_AS_OPERATIONAL_PACKAGE_NOMINATION_AUTHORITY"
echo "NOT_YET_ESTABLISHED=PERSISTED_EXACT_PROJECT_PACKAGE_VERSION_MISSION_SELECTION_EVENT"

echo
echo "=== AUTHORITY BOUNDARY ==="
echo "CURRENT_CORRIDOR=OPERATIONAL_PACKAGE_AUTHORITY"
echo "QUESTION=WHAT_AUTHORITY_SELECTS_AN_ALREADY_CANONICAL_PACKAGE_AS_THE_OPERATIONAL_MISSION_BEFORE_MISSION_READ_STAGE_DERIVATION"
echo "DELEGATION_AUTHORITY_REMAINS_DISTINCT=YES"
echo "VALIDATION_AUTHORITY_REMAINS_DISTINCT=YES"
echo "LIFECYCLE_AUTHORITY_REMAINS_DISTINCT=YES"

echo
echo "=== SCOPE ==="
echo "VERIFIED_OUTCOME=PRODUCTION_DELEGATION_PACKAGE_ROOT_RECONCILIATION_COMPLETE"
echo "DEFERRED=VALIDATION_GATE_ENVELOPE_CANONICAL_LINEAGE_RECONCILIATION"
echo "PROPOSED_IMPLEMENTATION=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=DETERMINE_FROM_REPOSITORY_EVIDENCE_WHETHER_OPERATIONAL_PACKAGE_NOMINATION_AUTHORITY_ALREADY_EXISTS_OR_IS_AN_ABSENT_ARCHITECTURAL_BOUNDARY"
