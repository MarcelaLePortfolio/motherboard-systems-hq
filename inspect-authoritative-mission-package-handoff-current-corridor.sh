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
echo "=== PRESERVED CORRECTIONS ==="
echo "PRODUCTION_DELEGATION_PACKAGE_ROOT_RECONCILIATION=COMPLETE_AND_VALIDATED"
echo "CURRENT_CANONICAL_PACKAGE_DELEGATION_EVENT=PENDING_OPERATOR_AUTHORITY"
echo "PENDING_DELEGATION_IS_NOT_RUNTIME_IMPLEMENTATION_FAILURE=YES"
echo "DOWNSTREAM_VALIDATION_GATE_ENVELOPE_DEFECT=SEPARATELY_DEFERRED"
echo "DO_NOT_AUTO_DELEGATE=YES"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== FIND AUTHORITATIVE MISSION PACKAGE HANDOFF STATE ==="
rg -n -C 18 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'AUTHORITATIVE MISSION PACKAGE HANDOFF|Authoritative Mission Package Handoff|Operational Package Authority|Package Handoff Contract|Project-Bound Handoff|Mission Control Intake|Handoff Validation|Mission Package Handoff' \
  docs/governance docs/checkpoints . \
  2>/dev/null | head -n 3600

echo
echo "=== OPERATIONAL PACKAGE AUTHORITY EVIDENCE ==="
rg -n -C 16 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'operational package|Operational Package|mission identity|Mission identity|package_id.*package_version|project_id.*package_id|handoff|nominate|nomination|activate.*package|active.*package' \
  docs/governance db server client/src \
  2>/dev/null | head -n 3600

echo
echo "=== MISSION READ STAGE CAPABILITY ==="
sed -n '1,260p' db/mission-read-model-assembler.ts

echo
echo "=== MISSION READ ROOT ==="
sed -n '1,180p' db/mission-read-repository.ts

echo
echo "=== MISSION CONTROL PACKAGE SELECTION ==="
rg -n -C 16 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  'ACTIVE_PACKAGE_ID|loadMission\(|corridor-smoke|packageId|package_id|activeProjectId' \
  client/src db server \
  2>/dev/null | head -n 2800

echo
echo "=== CANONICAL PACKAGE LIVE STATE ==="
sqlite3 -header -column db/main.db "
SELECT
  package_id,
  package_version,
  project_id,
  conversation_id,
  status,
  approved_at,
  created_at
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
echo "=== SEARCH FOR EXACT MISSION NOMINATION RECORD ==="
rg -n -C 14 \
  --hidden \
  --glob '!node_modules/**' \
  --glob '!.git/**' \
  --glob '!snapshots/**' \
  --glob '!scripts_backup*/**' \
  --glob '!*.bak' \
  'mission_package|mission package|mission_identity|mission identity|operational_package|operational package|handoff_record|handoff record|package_nomination|package nomination|active_package|selected_package' \
  db drizzle server client/src docs/governance \
  2>/dev/null | head -n 3200

echo
echo "=== AUTHORITY FALSIFICATION QUESTIONS ==="
echo "Q1=DOES_CANONICAL_APPROVAL_SEMANTICALLY_NOMINATE_THE_PACKAGE_AS_MISSION_CONTROL_MISSION"
echo "Q2=DOES_EXPLICIT_DELEGATION_SEMANTICALLY_NOMINATE_THE_PACKAGE_AS_MISSION_CONTROL_MISSION_OR_ONLY_AUTHORIZE_INTERPRETATION"
echo "Q3=DOES_ANY_EXISTING_PERSISTED_RECORD_EXPLICITLY_CARRY_PROJECT_ID_PACKAGE_ID_PACKAGE_VERSION_AS_OPERATIONAL_MISSION_IDENTITY"
echo "Q4=CAN_MISSION_CONTROL_SELECT_A_PACKAGE_WITHOUT_RECENCY_APPROVAL_UI_OR_PROJECT_ONLY_INFERENCE"
echo "Q5=IS_A_NEW_HANDOFF_CONTRACT_ACTUALLY_MISSING_OR_DOES_AN_EXISTING_AUTHORITY_EVENT_ALREADY_SATISFY_THE_ROLE"

echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "CURRENT_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "CURRENT_CORRIDOR=OPERATIONAL_PACKAGE_AUTHORITY"
echo "DELEGATION_CORRIDOR_REOPENED=NO"
echo "EXPLICIT_OPERATOR_DELEGATION_TRIGGERED=NO"
echo "DOWNSTREAM_SCHEMA_RECONCILIATION_REOPENED=NO"
echo "PROPOSED_IMPLEMENTATION=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_DECISION=DETERMINE_WHAT_AUTHORITATIVE_PERSISTED_EVENT_OR_STATE_NOMINATES_EXACT_PROJECT_ID_PACKAGE_ID_PACKAGE_VERSION_AS_MISSION_IDENTITY_WITHOUT_INFERENCE"
