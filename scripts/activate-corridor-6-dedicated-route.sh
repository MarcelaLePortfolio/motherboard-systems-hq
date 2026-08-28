#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

EXPECTED_HEAD_PREFIX="6dd548564"
CURRENT_HEAD="$(git rev-parse HEAD)"

echo "=== CORRIDOR 6 DEDICATED ROUTE ACTIVATION ==="
echo "EXPECTED_HEAD_PREFIX=${EXPECTED_HEAD_PREFIX}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
echo "RECOVERY_POINT=DR_20260828_102500"
echo "AUTHORIZATION=BOUNDED_DEDICATED_ROUTE_MOUNT_AND_PRODUCTION_REACHABILITY"

if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

test -f server/routes/governance-execution-route.ts
test -f server/execution/production-governance-execution-composition.ts

ROUTE_FACTORY="$(
  grep -Eo 'export (async )?function [A-Za-z0-9_]+' \
    server/routes/governance-execution-route.ts | head -n1 | awk '{print $NF}'
)"

COMPOSITION_EXPORT="$(
  grep -Eo 'export (async )?function [A-Za-z0-9_]+' \
    server/execution/production-governance-execution-composition.ts | head -n1 | awk '{print $NF}'
)"

[[ -n "${ROUTE_FACTORY}" && -n "${COMPOSITION_EXPORT}" ]]

python3 - "${ROUTE_FACTORY}" "${COMPOSITION_EXPORT}" << 'PY'
from pathlib import Path
import sys

route_factory = sys.argv[1]
composition_export = sys.argv[2]
path = Path("server/index.ts")
text = path.read_text()

route_import = f'import {{ {route_factory} }} from "./routes/governance-execution-route.js";'
composition_import = (
    f'import {{ {composition_export} }} from '
    '"./execution/production-governance-execution-composition.js";'
)

if route_import not in text:
    lines = text.splitlines()
    last_import = max(i for i, line in enumerate(lines) if line.startswith("import "))
    lines[last_import + 1:last_import + 1] = [route_import, composition_import]
    text = "\n".join(lines) + "\n"

if "CORRIDOR_6_DEDICATED_ROUTE_MOUNT" not in text:
    marker = "const port = process.env.PORT || 3000;"
    if marker not in text:
        raise SystemExit("Known listen boundary not found; refusing speculative edit.")

    block = f'''// CORRIDOR_6_DEDICATED_ROUTE_MOUNT
const governanceExecutionComposition = {composition_export}();
app.use(
  "/api/governance/execution",
  {route_factory}(governanceExecutionComposition),
);

'''
    text = text.replace(marker, block + marker, 1)

path.write_text(text)
PY

npx tsx --test \
  server/routes/governance-execution-route.test.ts \
  server/execution/production-execution-entry-point.test.ts \
  db/governance-execution-read-repository.test.ts \
  db/governance-execution-approval-persistence.test.ts \
  db/governance-execution-scope-persistence.test.ts

npx tsc --noEmit
npm run build

if [[ -f /tmp/motherboard-backend.pid ]]; then
  OLD_PID="$(cat /tmp/motherboard-backend.pid 2>/dev/null || true)"
  if [[ -n "${OLD_PID}" ]] && kill -0 "${OLD_PID}" 2>/dev/null; then
    kill "${OLD_PID}"
    sleep 1
  fi
fi

nohup node dist/server/index.js >/tmp/motherboard-backend.log 2>&1 &
echo "$!" >/tmp/motherboard-backend.pid

for _ in $(seq 1 15); do
  lsof -nP -iTCP:3000 -sTCP:LISTEN >/dev/null 2>&1 && break
  sleep 1
done

REGISTRY_STATUS="$(
  curl -sS -o /tmp/corridor6-registry.json -w '%{http_code}' \
    http://127.0.0.1:5173/api/projects/registry || true
)"
[[ "${REGISTRY_STATUS}" == "200" ]]

ROUTE_STATUS="$(
  curl -sS -o /tmp/corridor6-route-response.json -w '%{http_code}' \
    -X POST \
    -H 'Content-Type: application/json' \
    --data '{}' \
    http://127.0.0.1:3000/api/governance/execution || true
)"

if [[ "${ROUTE_STATUS}" == "404" || "${ROUTE_STATUS}" == "000" ]]; then
  echo "DEDICATED_ROUTE_PRODUCTION_REACHABILITY=FAIL"
  exit 1
fi

echo "COMPILED_SERVER_RUNTIME=PASS"
echo "DASHBOARD_RUNTIME_HEALTH=PASS"
echo "DEDICATED_ROUTE_PRODUCTION_REACHABILITY=PASS"
echo "REAL_GIT_EFFECT_ATTEMPTED=NO"
echo "GENERIC_CADE_REACHABILITY=NO"
echo "AUTHORITY_EXPANSION=NO"
echo "CORRIDOR_6_STATUS=READY_FOR_CLOSURE_DETERMINATION"
echo "PHASE_1_STATUS=ACTIVE_PENDING_CORRIDOR_6_CLOSURE"
