#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== DERIVE VALID EMPTY MISSION PRESENTATION CONTRACT ==="
echo "BASELINE_COMMIT=6c562b9d"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== VERIFIED DEFECT ==="
echo "INTRODUCING_COMMIT=d74a8e44"
echo "FAILURE_CLASS=INVALID_EMPTY_MISSION_PRESENTATION_MODEL"
echo "CURRENT_EMPTY_OBJECT_DOES_NOT_SATISFY_EXISTING_MODEL=YES"
echo "MODEL_CONTRACT_CHANGE_REQUIRED=NO_EVIDENCE"

echo
echo "=== COMPLETE PRESENTATION MODEL ==="
sed -n '/export interface MissionPresentationModel {/,/^}/p' \
  client/src/mission-control/missionPresentationMapper.ts

echo
echo "=== CANONICAL MAPPER OUTPUT ==="
rg -n -C 12 \
  'return \{|requestedOutcome:|artifactCount:|lifecycleEventCount:|integrityWarnings:|latestTimestamp:|timeline:|startedTimestamp:|progressStages:|progressPosition:|progressTotal:|nextStageLabel:' \
  client/src/mission-control/missionPresentationMapper.ts \
  2>/dev/null || true

echo
echo "=== CARD FIELD CONSUMPTION ==="
rg -n -C 4 \
  'mission\.(packageId|projectId|version|requestedOutcome|stage|owner|health|awaiting|artifactCount|lifecycleEventCount|integrityWarnings|latestTimestamp|timeline|startedTimestamp|progressStages|progressPosition|progressTotal|nextStageLabel)' \
  client/src/shell/MissionDashboardWorkspace.tsx \
  2>/dev/null || true

echo
echo "=== INVALID NON-CONTRACT FIELDS IN CURRENT EMPTY OBJECT ==="
rg -n \
  'evidenceCount:|latestEvent:|nextStep:|activeAgent:' \
  client/src/shell/MissionDashboardWorkspace.tsx \
  2>/dev/null || true

echo
echo "=== DERIVATION BOUNDARY ==="
echo "EMPTY_STATE_MUST_USE_ONLY_EXISTING_MissionPresentationModel_FIELDS=YES"
echo "OWNER_MUST_BE_STRING=YES"
echo "PROJECT_ID_MAY_BE_NULL=YES"
echo "NULLABLE_FIELDS_MAY_USE_NULL_ONLY_WHERE_MODEL_PERMITS=YES"
echo "ARRAY_FIELDS_REQUIRE_ARRAY_VALUES=YES"
echo "TIMELINE_EMPTY_STATE_CAN_BE_EMPTY_ARRAY_IF_CARD_CONSUMERS_SUPPORT_NO_EVENTS=TO_BE_CONFIRMED_FROM_OUTPUT"
echo "PROGRESS_TOTAL_MUST_PRESERVE_EXISTING_PRESENTATION_SEMANTICS=TO_BE_DERIVED_NOT_GUESSED"
echo "NON_CONTRACT_FIELDS_MUST_NOT_BE_USED_TO_FAKE_EMPTY_STATE=YES"
echo "DOMAIN_MODEL_CHANGE_AUTHORIZED=NO"
echo "CLIENT_IMPLEMENTATION_CHANGE_AUTHORIZED=NO"

echo
echo "NEXT_ACTION=CLASSIFY_EXACT_EVIDENCE_SUPPORTED_VALUES_FOR_EVERY_REQUIRED_EMPTY_MISSION_FIELD_AND_THEN_AUTHORIZE_ONE_NARROW_FIX"
