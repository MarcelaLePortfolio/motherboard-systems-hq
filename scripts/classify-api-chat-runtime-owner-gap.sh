#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=99215d98' \
  'MODE=DIAGNOSTIC_ONLY' \
  'PRODUCTION_CHANGE=NONE' \
  'OBSERVED_HTTP_STATUS=000' \
  'OBSERVED_CURL_ERROR=ECONNREFUSED_127_0_0_1_8080' \
  'UI_503_REPRODUCED=NO' \
  'DETERMINATION=LOCAL_PORT_8080_IS_NOT_THE_ACTIVE_DASHBOARD_BACKEND_RUNTIME' \
  'NEXT_ACTION=IDENTIFY_ACTUAL_DASHBOARD_BACKEND_RUNTIME_AND_PORT'

printf '\n=== PROCESS LIST ===\n'
ps aux | grep -E '[n]ode|[t]sx|[v]ite|[n]ext|[p]npm|[n]pm|[o]llama' || true

printf '\n=== LISTENING TCP PORTS ===\n'
lsof -nP -iTCP -sTCP:LISTEN | \
  grep -E 'node|tsx|vite|npm|pnpm|3000|3001|4000|5000|5173|8000|8080|8787' || true

printf '\n=== PACKAGE RUNTIME COMMANDS ===\n'
node -e '
  const fs = require("fs");
  const pkg = JSON.parse(fs.readFileSync("package.json", "utf8"));
  console.log(JSON.stringify(pkg.scripts || {}, null, 2));
'

printf '\n=== CLIENT API BASE / PROXY CONFIG ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'proxy|server\.proxy|baseURL|API_BASE|VITE_|localhost:[0-9]+|127\.0\.0\.1:[0-9]+|/api/chat' \
  vite.config.* client package.json server routes 2>/dev/null | head -320

printf '\n=== SERVER LISTEN CONFIG ===\n'
grep -Rni --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=.next \
  -E 'listen\(|PORT|process\.env\.PORT|8080|3000|5173' \
  server index.* package.json 2>/dev/null | head -260

printf '\n=== KNOWN CLOUDFLARE / TUNNEL MAP ===\n'
if [[ -f /mnt/data/cloudflare-tunnel-map.txt ]]; then
  cat /mnt/data/cloudflare-tunnel-map.txt
fi

printf '\n=== CLASSIFICATION ===\n'
printf '%s\n' \
  'LOCAL_8080_BACKEND_AVAILABLE=NO' \
  'DASHBOARD_RUNTIME_OWNER=NOT_YET_IDENTIFIED' \
  '503_ROOT_CAUSE=STILL_UNRESOLVED' \
  'FIX_AUTHORIZED=NO' \
  'NEXT_ACTION=RETRY_EXACT_API_CHAT_CALL_AGAINST_IDENTIFIED_RUNTIME'

printf '\n=== WORKTREE ===\n'
git status --short
