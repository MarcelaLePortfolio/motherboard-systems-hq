#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== BEGIN PROJECT-BOUND HANDOFF SCOPE DETERMINATION ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "CLOSED_CORRIDOR=PACKAGE_HANDOFF_CONTRACT"
echo "ACTIVE_CORRIDOR=PROJECT_BOUND_HANDOFF"
echo "PACKAGE_HANDOFF_CONTRACT_CLOSURE_COMMIT=2e4b3e6f"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== ESTABLISHED INPUTS ==="
echo "ACTIVE_PROJECT_IDENTITY_SOURCE=PROJECT_REGISTRY"
echo "AUTHORITATIVE_PACKAGE_SOURCE=EXACT_canonical_approved_PACKAGE"
echo "MISSION_PACKAGE_PROJECTION_SOURCE=governance_packages"
echo "REQUIRED_OPERATIONAL_IDENTITY=project_id+package_id+package_version"
echo "MISSION_CONTROL_IS_READ_ONLY=YES"
echo "MISSION_CONTROL_MAY_SELECT_PACKAGE=NO"
echo "MISSION_CONTROL_MAY_CREATE_HANDOFF=NO"
echo "DELEGATION_IS_HANDOFF_AUTHORITY=NO"
echo "ACTIVE_PROJECT_ID_ALONE_SELECTS_PACKAGE=NO"

echo
echo "=== CURRENT REPOSITORY HANDOFF / SELECTION SURFACES ==="
rg -n -C 12 \
  'selectedPackage|operational package|operational_package|active package|ACTIVE_PACKAGE_ID|lastPackageId|loadMission|getMissionReadModel|activeProjectId|project_id.*package_id.*package_version|package_id.*package_version.*project_id' \
  client server db routes \
  2>/dev/null || true

echo
echo "=== MISSION CONTROL CURRENT CALL PATH ==="
rg -n -C 16 \
  'ACTIVE_PACKAGE_ID|loadMission|getMissionReadModel|MissionControlProvider|MissionDashboardWorkspace' \
  client/src \
  2>/dev/null || true

echo
echo "=== PROJECT REGISTRY CURRENT SURFACE ==="
rg -n -C 12 \
  'activeProjectId|project_registry|projectId|project_id' \
  server client db \
  2>/dev/null || true

echo
echo "=== OPERATIONAL PACKAGE AUTHORITY EVIDENCE ==="
rg -n -C 12 \
  'OPERATIONAL_PACKAGE_AUTHORITY|operational package authority|operational_package_authority|selected_package|selectedPackage' \
  . \
  --glob '!node_modules/**' \
  --glob '!dist/**' \
  --glob '!build/**' \
  2>/dev/null || true

echo
echo "=== LIVE PROJECT / PACKAGE STATE ==="
sqlite3 -header -column db/main.db '
SELECT
  c.project_id,
  c.package_id,
  c.package_version,
  c.status,
  g.project_id AS mission_project_id,
  g.package_id AS mission_package_id,
  g.package_version AS mission_package_version
FROM matilda_canonical_packages c
LEFT JOIN governance_packages g
  ON g.package_id = c.package_id
 AND g.package_version = c.package_version
WHERE c.status = "canonical_approved"
ORDER BY c.created_at DESC;
'

echo
echo "=== SCOPE QUESTIONS ==="
echo "QUESTION_1=WHERE_IS_THE_DEDICATED_PROJECT_SCOPED_OPERATIONAL_PACKAGE_AUTHORITY_PERSISTED_OR_IS_IT_STILL_UNIMPLEMENTED"
echo "QUESTION_2=WHAT_EXACT_RUNTIME_EVENT_BINDS_ACTIVE_PROJECT_IDENTITY_TO_EXPLICIT_OPERATIONAL_PACKAGE_IDENTITY"
echo "QUESTION_3=CAN_MISSION_CONTROL_CONSUME_THAT_BINDING_WITHOUT_GAINING_SELECTION_AUTHORITY"
echo "QUESTION_4=DOES_CURRENT_MISSION_READ_API_ACCEPT_THE_FULL_project_id+package_id+package_version_IDENTITY_OR_ONLY_package_id"
echo "QUESTION_5=WHAT_IS_THE_MINIMUM_PROJECT_BOUND_HANDOFF_UNIT_REQUIRED_BEFORE_MISSION_CONTROL_INTAKE_CAN_BEGIN"

echo
echo "=== CORRIDOR BOUNDARY ==="
echo "PACKAGE_HANDOFF_CONTRACT_REMAINS_CLOSED=YES"
echo "PROJECT_BOUND_HANDOFF_SCOPE_DETERMINATION=ACTIVE"
echo "PROJECT_BOUND_HANDOFF_IMPLEMENTATION_STARTED=NO"
echo "MISSION_CONTROL_INTAKE_STARTED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"
echo "NEXT_ACTION=CLASSIFY_PROJECT_BOUND_HANDOFF_CAPABILITY_AND_MINIMUM_MISSING_AUTHORITY_BRIDGE_FROM_REPOSITORY_EVIDENCE"
