#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== AUTHORITATIVE MISSION PACKAGE HANDOFF — CURRENT CORRIDOR ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== FAILURE CLASSIFICATION ==="
echo "FAILED_HYPOTHESIS=NO"
echo "REPOSITORY_DEFECT_ESTABLISHED=NO"
echo "INSPECTION_SCRIPT_DEFECT=YES"
echo "DEFECT=QUERY_REFERENCED_NONEXISTENT_APPROVED_AT_COLUMN"
echo "PRIOR_EVIDENCE_INVALIDATED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "=== ACTUAL CANONICAL PACKAGE TABLE CONTRACT ==="
sqlite3 db/main.db ".schema matilda_canonical_packages"
sqlite3 -header -column db/main.db "PRAGMA table_info(matilda_canonical_packages);"

echo
echo "=== CANONICAL PACKAGE LIVE STATE ==="
sqlite3 -header -column db/main.db "
SELECT *
FROM matilda_canonical_packages
ORDER BY created_at;
"

echo
echo "=== CURRENT DELEGATION LIVE STATE ==="
sqlite3 -header -column db/main.db "
SELECT
  delegation_id,
  package_id,
  package_version,
  authorization_state,
  authorization_timestamp,
  delegated_by,
  created_at
FROM governance_delegations
ORDER BY created_at;
"

echo
echo "=== OPERATIONAL PACKAGE AUTHORITY / HANDOFF EVIDENCE ==="
rg -n -C 18 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'AUTHORITATIVE MISSION PACKAGE HANDOFF|Authoritative Mission Package Handoff|Operational Package Authority|mission identity|Mission identity|operational package|Operational Package|handoff|nomination|active_package|selected_package|loadMission\(' \
  docs/governance db server client/src \
  2>/dev/null | head -n 4200

echo
echo "=== MISSION READ ROOT ==="
sed -n '1,260p' db/mission-read-repository.ts

echo
echo "=== MISSION READ MODEL ASSEMBLY ==="
sed -n '1,300p' db/mission-read-model-assembler.ts

echo
echo "=== AUTHORITY FALSIFICATION QUESTIONS ==="
echo "Q1=DOES_CANONICAL_APPROVAL_NOMINATE_THE_PACKAGE_AS_THE_OPERATIONAL_MISSION"
echo "Q2=DOES_DELEGATION_NOMINATE_THE_PACKAGE_AS_THE_OPERATIONAL_MISSION_OR_ONLY_AUTHORIZE_DOWNSTREAM_INTERPRETATION"
echo "Q3=DOES_ANY_PERSISTED_RECORD_EXPLICITLY_BIND_PROJECT_ID_PACKAGE_ID_PACKAGE_VERSION_AS_MISSION_IDENTITY"
echo "Q4=CAN_MISSION_CONTROL_SELECT_THE_PACKAGE_WITHOUT_RECENCY_UI_OR_PROJECT_ONLY_INFERENCE"
echo "Q5=IS_A_NEW_HANDOFF_AUTHORITY_CONTRACT_MISSING_OR_DOES_AN_EXISTING_AUTHORITY_EVENT_ALREADY_SATISFY_IT"

echo
echo "=== SCOPE DETERMINATION ==="
echo "VERIFIED_OUTCOME=PRODUCTION_DELEGATION_PACKAGE_ROOT_RECONCILIATION_COMPLETE"
echo "VERIFIED_OUTCOME=PENDING_OPERATOR_DELEGATION_IS_NOT_INCOMPLETE_RUNTIME_IMPLEMENTATION"
echo "CURRENT_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "CURRENT_CORRIDOR=OPERATIONAL_PACKAGE_AUTHORITY"
echo "DELEGATION_CORRIDOR_REOPENED=NO"
echo "EXPLICIT_OPERATOR_DELEGATION_TRIGGERED=NO"
echo "DOWNSTREAM_VALIDATION_GATE_ENVELOPE_RECONCILIATION=DEFERRED"
echo "PROPOSED_IMPLEMENTATION=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=IDENTIFY_THE_EXISTING_OR_MISSING_AUTHORITATIVE_PERSISTED_EVENT_THAT_NOMINATES_EXACT_PROJECT_ID_PACKAGE_ID_PACKAGE_VERSION_AS_MISSION_IDENTITY"
