#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=f2a36edb' \
  'MODE=COLLABORATION_DIAGNOSTIC' \
  'ISSUE_RESOLVED=NO' \
  'BACKEND_API=PASS' \
  'PORT_5173_OCCUPIED=YES' \
  'NEW_VITE_INSTANCE_STARTED_ON_5174=YES' \
  'TARGET=CLASSIFY_EXISTING_5173_RUNTIME_AND_SAFE_NEXT_STEP'

printf '\n=== PORT 5173 PROCESS ===\n'
lsof -nP -iTCP:5173 -sTCP:LISTEN || true

PORT_PID="$(lsof -tiTCP:5173 -sTCP:LISTEN | head -1 || true)"
echo "PORT_5173_PID=${PORT_PID:-NONE}"

if [[ -n "${PORT_PID:-}" ]]; then
  printf '\n=== PROCESS DETAILS ===\n'
  ps -p "$PORT_PID" -o pid=,ppid=,etime=,command= || true

  printf '\n=== PROCESS WORKING DIRECTORY ===\n'
  lsof -a -p "$PORT_PID" -d cwd -Fn 2>/dev/null || true
fi

printf '\n=== LOCALHOST 5173 HEALTH ===\n'
LOCALHOST_CODE="$(curl -sS --max-time 5 -o /tmp/dashboard-5173-localhost.html -w '%{http_code}' http://localhost:5173/ 2>/dev/null || true)"
echo "LOCALHOST_5173_HTTP_STATUS=$LOCALHOST_CODE"

printf '\n=== IPV4 5173 HEALTH ===\n'
IPV4_CODE="$(curl -sS --max-time 5 -o /tmp/dashboard-5173-ipv4.html -w '%{http_code}' http://127.0.0.1:5173/ 2>/dev/null || true)"
echo "IPV4_5173_HTTP_STATUS=$IPV4_CODE"

printf '\n=== LOCALHOST 5174 HEALTH ===\n'
PORT_5174_CODE="$(curl -sS --max-time 5 -o /tmp/dashboard-5174-localhost.html -w '%{http_code}' http://localhost:5174/ 2>/dev/null || true)"
echo "LOCALHOST_5174_HTTP_STATUS=$PORT_5174_CODE"

printf '\n=== VITE CONFIG ===\n'
sed -n '1,220p' client/vite.config.ts

printf '\n=== CLASSIFICATION ===\n'
if [[ "$LOCALHOST_CODE" == "200" ]]; then
  printf '%s\n' \
    'EXISTING_PORT_5173_RUNTIME=HEALTHY' \
    'BINDING=IPV6_LOCALHOST' \
    'PREVIOUS_127_0_0_1_HEALTH_CHECK=FALSE_NEGATIVE' \
    'CLIENT_RESTART_REQUIRED=NO' \
    'SAFE_NEXT_STEP=VERIFY_DASHBOARD_PROXY_CHAT_VIA_LOCALHOST_5173'
elif [[ "$PORT_5174_CODE" == "200" ]]; then
  printf '%s\n' \
    'EXISTING_PORT_5173_RUNTIME=NOT_HEALTHY_VIA_LOCALHOST' \
    'NEW_PORT_5174_RUNTIME=HEALTHY' \
    'SAFE_NEXT_STEP=CLASSIFY_5173_PROCESS_OWNERSHIP_BEFORE_TERMINATION'
else
  printf '%s\n' \
    'EXISTING_PORT_5173_RUNTIME=UNHEALTHY' \
    'NEW_PORT_5174_RUNTIME=UNHEALTHY_OR_UNREACHABLE' \
    'SAFE_NEXT_STEP=CLASSIFY_CLIENT_RUNTIME_WITHOUT_TERMINATING_UNKNOWN_PROCESS'
fi

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'PROCESS_TERMINATED=NO' \
  'CLIENT_CONFIG_CHANGE=NO' \
  'BACKEND_CHANGE=NO' \
  'VALIDATOR_CHANGE=NO' \
  'GENERATION_POLICY_CHANGE=NO' \
  'NEW_FIX_AUTHORIZED=NO'

printf '\n=== WORKTREE ===\n'
git status --short
