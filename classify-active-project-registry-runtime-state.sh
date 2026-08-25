#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY ACTIVE PROJECT REGISTRY RUNTIME STATE ==="
echo "BASELINE_COMMIT=0f898f07"
echo "OBSERVED_MISSION_CONTROL=PREPARING_MISSION_CONTROL"
echo "OBSERVED_APPROVALS=NO_ACTIVE_PROJECT_IS_AVAILABLE"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== VERIFIED SHARED CLIENT DEPENDENCY ==="
echo "MISSION_CONTROL_ACTIVE_PROJECT_SOURCE=ProjectContextProvider.registry.activeProjectId"
echo "APPROVALS_ACTIVE_PROJECT_SOURCE=ProjectContextProvider.registry.activeProjectId"
echo "PROJECT_CONTEXT_PROVIDER_INITIAL_LOAD=getProjectRegistry"
echo "PROJECT_REGISTRY_ENDPOINT=/api/projects/registry"

echo
echo "=== LIVE ACTIVE_CONTEXT TABLE ==="
sqlite3 -header -column db/main.db '
SELECT
  singleton_id,
  current_project_id,
  source,
  action,
  updated_at
FROM active_context;
' 2>/dev/null || true

echo
echo "=== ACTIVE CONTEXT / PROJECT JOIN ==="
sqlite3 -header -column db/main.db '
SELECT
  a.current_project_id,
  p.display_name,
  p.registration_status,
  p.availability_status,
  p.active_context_eligible,
  p.last_opened_at
FROM active_context a
LEFT JOIN project_registry p
  ON p.project_id = a.current_project_id
WHERE a.singleton_id = 1;
' 2>/dev/null || true

echo
echo "=== DIRECT SERVER REGISTRY STATE ==="
node --input-type=module <<'NODE'
const registry = await import("./server/project-registry.mjs");
const state = registry.getProjectRegistryState();

console.log(JSON.stringify({
  activeProjectId: state.activeProjectId,
  activeProject: state.activeProject,
  activeContext: state.activeContext,
  projectCount: state.projects.length,
}, null, 2));
NODE

echo
echo "=== HTTP REGISTRY ENDPOINT ==="
HTTP_BODY="$(mktemp)"
HTTP_CODE="$(curl -sS -o "${HTTP_BODY}" -w '%{http_code}' http://127.0.0.1:3000/api/projects/registry || true)"
echo "HTTP_STATUS=${HTTP_CODE}"
cat "${HTTP_BODY}" 2>/dev/null || true
rm -f "${HTTP_BODY}"

echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "PROJECT_ROWS_EXIST=YES"
echo "PERSISTENCE_PROJECT_REGISTRY_MISSING=NO"
echo "IF_DIRECT_STATE_HAS_ACTIVE_PROJECT_BUT_HTTP_DOES_NOT=SERVER_ROUTE_OR_RUNNING_PROCESS_GAP"
echo "IF_HTTP_HAS_ACTIVE_PROJECT_BUT_UI_DOES_NOT=CLIENT_PROJECT_CONTEXT_LOAD_OR_MOUNT_GAP"
echo "IF_DIRECT_STATE_LACKS_ACTIVE_PROJECT=ACTIVE_CONTEXT_PERSISTENCE_GAP"
echo "MISSION_CONTROL_LOCAL_TELEMETRY_FIX_REOPENED=NO"
echo "APPROVALS_LOCAL_IMPLEMENTATION_AUTHORIZED=NO"

echo
echo "NEXT_ACTION=CLASSIFY_EXACT_ACTIVE_PROJECT_FAILURE_LAYER_FROM_DIRECT_STATE_AND_HTTP_RESULTS"
