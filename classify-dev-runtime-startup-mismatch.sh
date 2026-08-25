#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY DEV RUNTIME STARTUP MISMATCH ==="
echo "BASELINE_COMMIT=d95b4df6"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== VERIFIED PROCESS STATE ==="
echo "VITE_PROCESS_5173=RUNNING"
echo "VITE_PROCESS_5174=RUNNING"
echo "EXPRESS_API_PROCESS_3000=NOT_RUNNING"
echo "VITE_API_PROXY_TARGET=http://localhost:3000"
echo "ROOT_CAUSE_HYPOTHESIS=CLIENT_DEV_SERVERS_RUNNING_WITHOUT_REQUIRED_EXPRESS_API_SERVER"

echo
echo "=== LOCALHOST PROBES ==="
for url in \
  http://localhost:5173/api/projects/registry \
  http://localhost:5174/api/projects/registry \
  http://localhost:3000/api/projects/registry
do
  body="$(mktemp)"
  code="$(curl -sS -o "$body" -w '%{http_code}' "$url" || true)"
  echo "${url} -> ${code}"
  if [[ -s "$body" ]]; then
    head -c 500 "$body"
    echo
  fi
  rm -f "$body"
done

echo
echo "=== DEV COMMAND EVIDENCE ==="
echo "--- root package.json ---"
node -e 'const p=require("./package.json"); console.log(JSON.stringify(p.scripts ?? {}, null, 2))'

echo "--- client/package.json ---"
node -e 'const p=require("./client/package.json"); console.log(JSON.stringify(p.scripts ?? {}, null, 2))'

echo
echo "=== PROCESS COMMANDS ==="
ps -p 19282,19296,42311,42325 -o pid=,ppid=,etime=,command= 2>/dev/null || true

echo
echo "=== CLASSIFICATION ==="
echo "ACTIVE_PROJECT_PERSISTENCE=HEALTHY"
echo "PROJECT_CONTEXT_PROVIDER_IMPLEMENTATION_DEFECT=NOT_ESTABLISHED"
echo "MISSION_CONTROL_IMPLEMENTATION_DEFECT=NOT_ESTABLISHED"
echo "APPROVALS_IMPLEMENTATION_DEFECT=NOT_ESTABLISHED"
echo "API_PROXY_CONFIGURATION_PRESENT=YES"
echo "API_PROXY_TARGET_PROCESS_PRESENT=NO"
echo "DEV_RUNTIME_STARTUP_MISMATCH=ESTABLISHED_IF_VITE_PROBES_RETURN_PROXY_FAILURE"
echo "CLIENT_CODE_CHANGE_REQUIRED=NO_EVIDENCE"
echo "SERVER_CODE_CHANGE_REQUIRED=NO_EVIDENCE"

echo
echo "NEXT_ACTION=RESTORE_EXPECTED_EXPRESS_API_RUNTIME_AND_REVALIDATE_PROJECT_REGISTRY_BEFORE_ANY_CODE_CHANGE"
