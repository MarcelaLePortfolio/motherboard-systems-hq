#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="aba2f9adb"
PORT=3000
LOG="/tmp/motherboard-executive-inbox-runtime.log"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

npm run build
(
  cd client
  npm run build
)

OLD_PID="$(lsof -tiTCP:${PORT} -sTCP:LISTEN | head -1 || true)"

if [ -n "$OLD_PID" ]; then
  kill "$OLD_PID"

  for _ in $(seq 1 40); do
    if ! kill -0 "$OLD_PID" 2>/dev/null; then
      break
    fi
    sleep 0.25
  done
fi

nohup node dist/server/index.js > "$LOG" 2>&1 &
NEW_PID=$!

for _ in $(seq 1 40); do
  if lsof -tiTCP:${PORT} -sTCP:LISTEN >/dev/null 2>&1; then
    break
  fi
  sleep 0.25
done

LISTENER_PID="$(lsof -tiTCP:${PORT} -sTCP:LISTEN | head -1 || true)"
test -n "$LISTENER_PID"

echo "OLD_PID=${OLD_PID:-NONE}"
echo "NEW_PID=$NEW_PID"
echo "LISTENER_PID=$LISTENER_PID"
echo
echo "=== SERVER LOG ==="
cat "$LOG" || true
echo
echo "RUNTIME_RESTARTED=YES"
echo "NEXT_ACTION=HARD_REFRESH_BROWSER_AND_CONFIRM_DELEGATED_ITEM_IS_GONE"
