#!/bin/bash
set -euo pipefail

echo "=== HARD RESET index.html FROM REMOTE (FORCE OVERWRITE) ==="
git fetch origin
git checkout origin/phase119-dashboard-cognition-contract -- public/index.html

echo
echo "=== VERIFY FILE IS REAL HTML (NOT LITERAL STRING) ==="
head -n 20 public/index.html

echo
echo "=== REBUILD DASHBOARD ==="
docker compose build dashboard
docker compose up -d dashboard
sleep 3

echo
echo "=== OPEN CLEAN SESSION ==="
open -na "Google Chrome" --args --incognito http://localhost:8080/

echo
echo "If you still see a literal string, STOP — do not proceed further."
