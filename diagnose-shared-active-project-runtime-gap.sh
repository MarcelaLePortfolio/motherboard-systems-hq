#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== DIAGNOSE SHARED ACTIVE PROJECT RUNTIME GAP ==="
echo "OBSERVED_MISSION_CONTROL=PREPARING_MISSION_CONTROL"
echo "OBSERVED_APPROVALS=NO_ACTIVE_PROJECT_IS_AVAILABLE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== INITIAL CAUSAL CLASSIFICATION ==="
echo "SHARED_SYMPTOM=ACTIVE_PROJECT_ID_UNAVAILABLE_TO_MULTIPLE_CONSUMERS"
echo "MISSION_CONTROL_LOCAL_EMPTY_MISSION_FIX_FAILURE=NOT_ESTABLISHED"
echo "APPROVALS_LOCAL_FAILURE=NOT_ESTABLISHED"
echo "LIKELY_SHARED_BOUNDARY=ProjectContextProvider.registry.activeProjectId"

echo
echo "=== PROJECT CONTEXT PROVIDER ==="
rg -n -C 12 \
  'activeProjectId|registry|ProjectContextProvider|loadProject|fetch|project_registry|setRegistry|status' \
  client/src/project-context \
  2>/dev/null || true

echo
echo "=== SHELL PROVIDER MOUNTING ==="
rg -n -C 12 \
  'ProjectContextProvider|MissionControlProvider|Approval|Approvals|MissionDashboardWorkspace' \
  client/src \
  -g '*.tsx' \
  2>/dev/null || true

echo
echo "=== ACTIVE PROJECT CONSUMERS ==="
rg -n -C 8 \
  'activeProjectId|No active project is available|Preparing Mission Control' \
  client/src \
  -g '*.ts' -g '*.tsx' \
  2>/dev/null || true

echo
echo "=== SERVER PROJECT REGISTRY SURFACE ==="
rg -n -C 10 \
  'activeProjectId|active_project|project_registry|registry' \
  routes server db \
  -g '*.ts' \
  2>/dev/null || true

echo
echo "=== LIVE DATABASE PROJECT STATE ==="
sqlite3 -header -column db/main.db '
SELECT *
FROM project_registry;
' 2>/dev/null || true

echo
echo "=== NEXT ACTION ==="
echo "NEXT_ACTION=CLASSIFY_WHETHER_ACTIVE_PROJECT_IS_MISSING_IN_PERSISTENCE_NOT_LOADED_BY_PROVIDER_OR_LOST_AT_PROVIDER_MOUNT_BOUNDARY"
