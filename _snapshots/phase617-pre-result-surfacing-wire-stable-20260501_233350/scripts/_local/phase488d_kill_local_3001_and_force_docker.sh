#!/bin/bash
set -euo pipefail

echo "=== killing local node on :3001 ==="
PID=$(lsof -tiTCP:3001 -sTCP:LISTEN || true)
if [ -n "${PID:-}" ]; then
  kill -9 $PID
  echo "Killed PID $PID"
else
  echo "No process on 3001"
fi

echo
echo "=== verifying ports ==="
lsof -nP -iTCP:3001 -sTCP:LISTEN || echo "3001 cleared"
lsof -nP -iTCP:8080 -sTCP:LISTEN

echo
echo "=== open correct dashboard ==="
open http://localhost:8080/dashboard

echo
echo "Now HARD refresh (Cmd+Shift+R), open console, click Quick check."
