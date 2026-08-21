#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n============================================================\n'
printf '✅ CORRIDOR 5 · ALTERNATIVE IMPLEMENTATION ACCEPTANCE\n'
printf 'STATUS: VALIDATION ONLY\n'
printf '============================================================\n\n'

printf '%s\n' \
'IMPLEMENTATION_COMMIT=5f40dc7c' \
'PROTECTED_DR=2e8d5a54' \
'STABLE_RUNTIME_BASE=c828acb8' \
'IMPLEMENTATION_UNIT=MISSION_READ_CLIENT_EXPECTED_PROJECT_VALIDATION'

printf '\n=== VERIFY AUTHORIZED FILE SCOPE ===\n'
git diff --name-only cc4b1abd..5f40dc7c

printf '\n=== VERIFY ACTIVE PACKAGE ID UNCHANGED ===\n'
git diff --exit-code cc4b1abd..5f40dc7c -- \
  client/src/shell/MissionDashboardWorkspace.tsx | \
  grep -F 'ACTIVE_PACKAGE_ID' >/dev/null && {
    echo 'ACTIVE_PACKAGE_ID_CHANGED=YES'
    exit 1
  } || true
grep -Fq 'const ACTIVE_PACKAGE_ID = "corridor-smoke";' \
  client/src/shell/MissionDashboardWorkspace.tsx
echo 'ACTIVE_PACKAGE_ID_UNCHANGED=YES'

printf '\n=== VERIFY PROVIDER RESET/REMOUNT APPROACH NOT REINTRODUCED ===\n'
if grep -Fq 'useEffect(() => {' client/src/mission-control/MissionControlProvider.tsx; then
  echo 'PROVIDER_RESET_EFFECT_PRESENT=YES'
  exit 1
fi
echo 'PROVIDER_RESET_EFFECT_PRESENT=NO'

printf '\n=== VERIFY EXPECTED PROJECT VALIDATION ===\n'
grep -Fq 'expectedProjectId?: string | null' \
  client/src/mission-control/missionReadApi.ts
grep -Fq 'payload.mission.identity.project_id !== expectedProject' \
  client/src/mission-control/missionReadApi.ts
grep -Fq 'MissionReadProjectMismatchError' \
  client/src/mission-control/missionReadApi.ts
echo 'MISSION_READ_EXPECTED_PROJECT_VALIDATION=PASS'

printf '\n=== VERIFY DASHBOARD ACTIVE PROJECT TRANSPORT ===\n'
grep -Fq 'useProjectContext' \
  client/src/shell/MissionDashboardWorkspace.tsx
grep -Fq 'void loadMission(ACTIVE_PACKAGE_ID, activeProjectId);' \
  client/src/shell/MissionDashboardWorkspace.tsx
echo 'ACTIVE_PROJECT_TRANSPORT=PASS'

printf '\n=== VERIFY PROHIBITED SURFACES UNCHANGED ===\n'
for file in \
  routes/api-mission-read.ts \
  db/mission-read-repository.ts
do
  if git diff --quiet cc4b1abd..5f40dc7c -- "$file"; then
    printf '%s=UNCHANGED\n' "$file"
  else
    printf '%s=CHANGED\n' "$file"
    exit 1
  fi
done

printf '\n=== ACCEPTANCE DISPOSITION ===\n'
printf '%s\n' \
'STATIC_SCOPE_VALIDATION=PASS' \
'MISSION_READ_EXPECTED_PROJECT_VALIDATION=PASS' \
'ACTIVE_PROJECT_TRANSPORT=PASS' \
'PROVIDER_RESET_EFFECT_PRESENT=NO' \
'ACTIVE_PACKAGE_ID_UNCHANGED=YES' \
'MISSION_READ_BACKEND_UNCHANGED=YES' \
'MISSION_READ_REPOSITORY_UNCHANGED=YES' \
'LIVE_UI_FULL_DASHBOARD=OPERATOR_VERIFICATION_REQUIRED' \
'PREPARING_STATE_REGRESSION=OPERATOR_VERIFICATION_REQUIRED' \
'ADDITIONAL_IMPLEMENTATION_AUTHORIZED=NO'
