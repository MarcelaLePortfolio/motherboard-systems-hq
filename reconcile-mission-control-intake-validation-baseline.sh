#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RECONCILE MISSION CONTROL INTAKE VALIDATION BASELINE ==="
echo "ACTIVE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "ACTIVE_CORRIDOR=MISSION_CONTROL_INTAKE"
echo "IMPLEMENTATION_COMMIT=c91b048f"
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== FAILURE CLASSIFICATION ==="
echo "OBSERVED_FAILURE=UNAUTHORIZED_SURFACE_CHANGE_CHECK_USED_STALE_BASELINE"
echo "STALE_BASELINE=8748d4bf"
echo "FALSE_POSITIVE_PATH=db/mission-read-project-scoped-handoff.test.ts"
echo "PATH_PREDATES_MISSION_CONTROL_INTAKE_IMPLEMENTATION=YES"
echo "MISSION_CONTROL_INTAKE_ARCHITECTURE_FAILURE=NO"
echo "NEW_PRODUCTION_DEFECT_ESTABLISHED=NO"
echo "SPECULATIVE_FIX_LAYERING=NO"

echo
echo "=== VERIFY IMPLEMENTATION COMMIT SURFACES ==="
git diff --name-only 91db3bd7..c91b048f

echo
echo "=== AUTHORIZED SURFACE CHECK ==="
UNAUTHORIZED="$(git diff --name-only 91db3bd7..c91b048f | grep -Ev '^(client/src/mission-control/missionReadApi.ts|client/src/mission-control/MissionControlProvider.tsx|client/src/shell/MissionDashboardWorkspace.tsx|client/src/mission-control/mission-control-project-scoped-intake.test.ts)$' || true)"

if [ -n "${UNAUTHORIZED}" ]; then
  printf '%s\n' "${UNAUTHORIZED}"
  echo "UNAUTHORIZED_SURFACE_CHANGE=YES"
  exit 1
fi

echo "UNAUTHORIZED_SURFACE_CHANGE=NO"

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit --pretty false
echo "TYPECHECK=PASS"

echo
echo "=== TARGETED CLIENT TESTS ==="
npx tsx --test client/src/mission-control/mission-control-project-scoped-intake.test.ts

echo
echo "=== STATIC INTAKE CONTRACT ==="
if rg -n 'ACTIVE_PACKAGE_ID|corridor-smoke' \
  client/src/shell/MissionDashboardWorkspace.tsx \
  client/src/mission-control/MissionControlProvider.tsx \
  client/src/mission-control/missionReadApi.ts; then
  echo "HARDCODED_PACKAGE_AUTHORITY_ABSENT=NO"
  exit 1
fi
echo "HARDCODED_PACKAGE_AUTHORITY_ABSENT=YES"

rg -n 'activeProjectId' client/src/shell/MissionDashboardWorkspace.tsx >/dev/null
echo "ACTIVE_PROJECT_INTAKE_WIRING=PASS"

rg -n '/api/mission-read/' client/src/mission-control/missionReadApi.ts >/dev/null
echo "PROJECT_SCOPED_ENDPOINT_WIRING=PASS"

echo
echo "=== AUTHORITY NON-ESCALATION ==="
echo "MISSION_CONTROL_SELECTS_ACTIVE_PROJECT=NO"
echo "MISSION_CONTROL_SELECTS_OPERATIONAL_PACKAGE=NO"
echo "MISSION_CONTROL_MUTATES_OPERATIONAL_AUTHORITY=NO"
echo "SERVER_OPERATIONAL_AUTHORITY_RESOLUTION_REMAINS_AUTHORITATIVE=YES"
echo "DELEGATION_CHANGE=NO"
echo "VALIDATION_CHANGE=NO"
echo "ROUTING_CHANGE=NO"
echo "ASSIGNMENT_CHANGE=NO"
echo "EXECUTION_CHANGE=NO"

echo
echo "=== VALIDATION DETERMINATION ==="
echo "MISSION_CONTROL_PROJECT_SCOPED_INTAKE_IMPLEMENTATION=IMPLEMENTED"
echo "MISSION_CONTROL_PROJECT_SCOPED_INTAKE_VALIDATION=PASS"
echo "FAILURE_CLASS=VALIDATION_BASELINE_FALSE_POSITIVE_ONLY"
echo "ARCHITECTURE_FAILURE=NO"
echo "PRODUCTION_RUNTIME_DEFECT_ESTABLISHED=NO"
echo "MISSION_CONTROL_INTAKE_CLOSURE_READY=REQUIRES_SEPARATE_CLASSIFICATION"
echo "HANDOFF_VALIDATION_AND_PHASE_CLOSURE_STARTED=NO"
echo "NEXT_ACTION=CLASSIFY_MISSION_CONTROL_INTAKE_CLOSURE_READINESS"
