#!/usr/bin/env bash
set -u

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

OUT="docs/local_3000_process_inspection_$(date +%Y%m%d_%H%M%S).txt"

PID="$(lsof -tiTCP:3000 -sTCP:LISTEN 2>/dev/null | head -n 1 || true)"

{
echo "LOCAL :3000 PROCESS INSPECTION"
echo "Timestamp: $(date)"
echo

echo "==== PRIMARY FINDING ===="
if [ -n "$PID" ]; then
  echo "Process found listening on :3000"
  echo "PID: $PID"
else
  echo "No process found listening on :3000"
fi
echo

echo "==== PORT 3000 LISTENER ===="
lsof -nP -iTCP:3000 -sTCP:LISTEN || true
echo

if [ -n "$PID" ]; then
  echo "==== PROCESS SUMMARY ===="
  ps -p "$PID" -o pid=,ppid=,user=,etime=,command= || true
  echo

  echo "==== PROCESS OPEN FILES (FIRST 120) ===="
  lsof -p "$PID" 2>/dev/null | sed -n '1,120p' || true
  echo

  echo "==== PROCESS CWD / EXECUTABLE ===="
  lsof -a -p "$PID" -d cwd 2>/dev/null || true
  lsof -a -p "$PID" -d txt 2>/dev/null || true
  echo

  echo "==== PROCESS ENVIRONMENT HINTS ===="
  ps eww -p "$PID" 2>/dev/null | sed 's/ /\n/g' | grep -Ei 'PWD=|npm_|pnpm_|yarn_|NODE_ENV=|PORT=|INIT_CWD=|PROJECT|DASHBOARD|NEXT' || true
  echo
fi

echo "==== HTTP HEADERS :3000 ===="
curl -I -sS http://127.0.0.1:3000/ || true
echo

echo "==== HTTP BODY FIRST 120 LINES :3000 ===="
curl -sS http://127.0.0.1:3000/ | sed -n '1,120p' || true
echo

echo "==== HTML TITLE / DASHBOARD STRINGS ===="
curl -sS http://127.0.0.1:3000/ | grep -Ei '<title>|dashboard|reflections|operator-guidance|events/ops|events/reflections' || true
echo

echo "==== INTERPRETATION BOUNDARY ===="
echo "This inspection identifies what is currently serving :3000."
echo "It does not change runtime behavior."
echo "It does not restart Docker."
echo "It does not modify application code."
echo

} > "$OUT"

echo "Inspection written to:"
echo "$OUT"

echo
echo "----- INSPECTION PREVIEW -----"
sed -n '1,260p' "$OUT"
