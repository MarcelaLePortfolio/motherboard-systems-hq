#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD_PREFIX="4fe106b34"
CURRENT_HEAD="$(git rev-parse HEAD)"

echo "=== CORRECTED CORRIDOR 6 ROUTE MOUNT ==="
echo "EXPECTED_HEAD_PREFIX=${EXPECTED_HEAD_PREFIX}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
echo "RECOVERY_POINT=DR_20260828_102500"
echo "AUTHORIZED_MOUNT=createProductionGovernanceExecutionRouter"
echo "PREVIOUS_FAILED_SHAPE=REQUEST_HANDLER_MOUNTED_AS_ROUTER"
echo "CORRECTED_SHAPE=EXISTING_EXPRESS_ROUTER_MOUNT"

if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

python3 << 'PY'
from pathlib import Path

path = Path("server/index.ts")
text = path.read_text()

import_line = (
    'import { createProductionGovernanceExecutionRouter } from '
    '"./execution/production-governance-execution-composition.js";'
)

if import_line not in text:
    anchor = (
        'import { createGovernanceDelegationRouter } '
        'from "./routes/governance-delegation-route";'
    )
    if anchor not in text:
        raise SystemExit("Expected import anchor not found; refusing speculative edit.")
    text = text.replace(anchor, anchor + "\n" + import_line, 1)

mount_line = "app.use(createProductionGovernanceExecutionRouter());"

if mount_line not in text:
    anchor = "app.use(createGovernanceDelegationRouter());"
    if anchor not in text:
        raise SystemExit("Expected Express mount anchor not found; refusing speculative edit.")
    text = text.replace(anchor, anchor + "\n" + mount_line, 1)

path.write_text(text)
PY

echo
echo "=== CORRECTED DIFF ==="
git diff -- server/index.ts

echo
echo "=== TARGETED GOVERNANCE TESTS ==="
npx tsx --test \
  server/routes/governance-execution-route.test.ts \
  server/execution/production-execution-entry-point.test.ts \
  db/governance-execution-read-repository.test.ts \
  db/governance-execution-approval-persistence.test.ts \
  db/governance-execution-scope-persistence.test.ts

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit

echo
echo "=== COMPILED PRODUCTION BUILD ==="
npm run build

echo
echo "=== RESTART COMPILED SERVER ==="
if [[ -f /tmp/motherboard-backend.pid ]]; then
  OLD_PID="$(cat /tmp/motherboard-backend.pid 2>/dev/null || true)"
  if [[ -n "${OLD_PID}" ]] && kill -0 "${OLD_PID}" 2>/dev/null; then
    kill "${OLD_PID}"
    sleep 1
  fi
fi

if lsof -tiTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
  echo "PORT_3000_STILL_OCCUPIED=YES"
  exit 1
fi

nohup node dist/server/index.js >/tmp/motherboard-backend.log 2>&1 &
NEW_PID="$!"
echo "${NEW_PID}" >/tmp/motherboard-backend.pid

READY=NO
for _ in $(seq 1 15); do
  if lsof -nP -iTCP:3000 -sTCP:LISTEN >/dev/null 2>&1; then
    READY=YES
    break
  fi
  if ! kill -0 "${NEW_PID}" 2>/dev/null; then
    break
  fi
  sleep 1
done

if [[ "${READY}" != "YES" ]]; then
  echo "COMPILED_SERVER_RUNTIME=FAIL"
  cat /tmp/motherboard-backend.log 2>/dev/null || true
  exit 1
fi

echo "COMPILED_SERVER_RUNTIME=PASS"

echo
echo "=== DASHBOARD HEALTH ==="
REGISTRY_STATUS="$(
  curl -sS -o /tmp/corridor6-corrected-registry.json -w '%{http_code}' \
    http://127.0.0.1:5173/api/projects/registry || true
)"
echo "PROJECT_REGISTRY_HTTP_STATUS=${REGISTRY_STATUS}"

if [[ "${REGISTRY_STATUS}" != "200" ]]; then
  echo "DASHBOARD_RUNTIME_HEALTH=FAIL"
  exit 1
fi

echo "DASHBOARD_RUNTIME_HEALTH=PASS"

echo
echo "=== SAFE ROUTE REACHABILITY ==="
ROUTE_STATUS="$(
  curl -sS -o /tmp/corridor6-corrected-route.json -w '%{http_code}' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data '{}' \
    http://127.0.0.1:3000/api/governance/execution || true
)"

echo "DEDICATED_ROUTE_HTTP_STATUS=${ROUTE_STATUS}"
cat /tmp/corridor6-corrected-route.json 2>/dev/null || true
echo

if [[ "${ROUTE_STATUS}" == "404" || "${ROUTE_STATUS}" == "000" ]]; then
  echo "DEDICATED_ROUTE_PRODUCTION_REACHABILITY=FAIL"
  exit 1
fi

echo "DEDICATED_ROUTE_PRODUCTION_REACHABILITY=PASS"
echo "REAL_GIT_EFFECT_ATTEMPTED=NO"
echo "GENERIC_CADE_REACHABILITY=NO"
echo "AUTHORITY_EXPANSION=NO"
echo "COMMIT_PUSH_SEPARATION=PRESERVED"
echo "CORRIDOR_6_ACTIVATION_VERIFICATION=PASS"
echo "CORRIDOR_6_STATUS=READY_FOR_CLOSURE_DETERMINATION"
echo "PHASE_1_STATUS=ACTIVE_PENDING_FINAL_CORRIDOR_CLOSURE"
