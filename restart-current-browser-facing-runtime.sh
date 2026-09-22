#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
PORT="3000"
LOG_FILE="/tmp/motherboard-current-runtime.log"

echo "============================================================"
echo " BROWSER-FACING RUNTIME — CURRENT BUILD RESTART"
echo "============================================================"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "BASELINE_CONVERGED=YES"

npm run build
npm --prefix client run build

OLD_PID="$(lsof -tiTCP:${PORT} -sTCP:LISTEN | head -1 || true)"

test -n "$OLD_PID" || {
  echo "STOP=NO_EXISTING_PORT_3000_SERVER"
  exit 1
}

echo "OLD_PORT_3000_PID=$OLD_PID"

kill "$OLD_PID"

for _ in $(seq 1 40); do
  if ! kill -0 "$OLD_PID" >/dev/null 2>&1; then
    break
  fi
  sleep 0.25
done

if kill -0 "$OLD_PID" >/dev/null 2>&1; then
  echo "STOP=OLD_SERVER_DID_NOT_EXIT"
  exit 1
fi

PORT="$PORT" nohup node dist/server/index.js >"$LOG_FILE" 2>&1 &
NEW_PID=$!

for _ in $(seq 1 40); do
  if curl -fsS \
    "http://127.0.0.1:${PORT}/api/canonical-packages?project_id=hq" \
    >/tmp/current-canonical-packages.json 2>/dev/null
  then
    break
  fi

  if ! kill -0 "$NEW_PID" >/dev/null 2>&1; then
    echo "STOP=NEW_SERVER_EXITED"
    cat "$LOG_FILE"
    exit 1
  fi

  sleep 0.25
done

APPROVAL_STATUS="$(
  curl -sS \
    -o /tmp/current-approval-requests.json \
    -w '%{http_code}' \
    "http://127.0.0.1:${PORT}/api/approval-requests?project_id=hq"
)"

CANONICAL_STATUS="$(
  curl -sS \
    -o /tmp/current-canonical-packages.json \
    -w '%{http_code}' \
    "http://127.0.0.1:${PORT}/api/canonical-packages?project_id=hq"
)"

test "$APPROVAL_STATUS" = "200"
test "$CANONICAL_STATUS" = "200"
kill -0 "$NEW_PID"

echo
echo "============================================================"
echo " CURRENT RUNTIME VALIDATED"
echo "============================================================"
echo "NEW_PORT_3000_PID=$NEW_PID"
echo "APPROVAL_REQUEST_STATUS=$APPROVAL_STATUS"
echo "CANONICAL_PACKAGE_STATUS=$CANONICAL_STATUS"
echo "BROWSER_FACING_RUNTIME=CURRENT_BUILD"
echo "PRODUCT_PATCH_REQUIRED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=REFRESH_BROWSER_AND_CONFIRM_APPROVED_CANONICAL_PACKAGE"
echo "CLEAR_STOPPING_POINT=YES"
