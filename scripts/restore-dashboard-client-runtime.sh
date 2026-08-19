#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

LOG='/private/tmp/motherboard-dashboard-vite-runtime.log'

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=074b79f3' \
  'LIVE_BACKEND_API=PASS' \
  'DASHBOARD_CLIENT_RUNTIME=UNAVAILABLE' \
  'ISSUE_RESOLVED=NO' \
  'TARGET=RESTORE_VITE_CLIENT_RUNTIME_ONLY'

printf '\n=== CLIENT PACKAGE SCRIPTS ===\n'
node -e '
  const pkg = require("./client/package.json");
  console.log(JSON.stringify(pkg.scripts || {}, null, 2));
' 2>/dev/null || true

printf '\n=== EXISTING PORT 5173 OWNER ===\n'
lsof -nP -iTCP:5173 -sTCP:LISTEN || true

rm -f "$LOG"

(
  cd client
  nohup npm run dev > "$LOG" 2>&1 &
  echo $! > /tmp/motherboard-dashboard-vite.pid
)

CLIENT_READY=NO
for _ in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
  CODE="$(
    curl -sS \
      --max-time 5 \
      -o /tmp/motherboard-dashboard-client-health.html \
      -w '%{http_code}' \
      http://127.0.0.1:5173/ \
      2>/dev/null || true
  )"

  if [[ "$CODE" == "200" ]]; then
    CLIENT_READY=YES
    break
  fi

  sleep 1
done

echo "CLIENT_READY=$CLIENT_READY"

printf '\n=== CLIENT LOG ===\n'
tail -120 "$LOG" || true

printf '\n=== CLIENT LISTENER ===\n'
lsof -nP -iTCP:5173 -sTCP:LISTEN || true

printf '\n=== CLASSIFICATION ===\n'
if [[ "$CLIENT_READY" == "YES" ]]; then
  printf '%s\n' \
    'DASHBOARD_CLIENT_RUNTIME=RESTORED' \
    'ISSUE_RESOLVED=NO' \
    'NEXT_ACTION=RERUN_DASHBOARD_PROXY_CHAT_VALIDATION'
else
  printf '%s\n' \
    'DASHBOARD_CLIENT_RUNTIME=FAILED_TO_START' \
    'ISSUE_RESOLVED=NO' \
    'NEXT_ACTION=CLASSIFY_CLIENT_STARTUP_FAILURE'
  exit 1
fi

printf '\n=== WORKTREE ===\n'
git status --short
