#!/usr/bin/env bash
set -euo pipefail

echo "=== CURRENT LISTENERS ==="
for port in 5173 3000 3001 8080 8787; do
  echo "--- PORT ${port} ---"
  lsof -nP -iTCP:${port} -sTCP:LISTEN || true
done

echo
echo "=== CLIENT VITE CONFIG ==="
sed -n '1,240p' client/vite.config.ts

echo
echo "=== CLIENT API REFERENCES ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  -E 'Project Registry unavailable|Preparing Mission Control|/api/|API_BASE|VITE_|localhost:[0-9]+' \
  client/src client 2>/dev/null | head -n 220 || true

echo
echo "=== BACKEND RUNTIME ==="
ps aux | grep -E '[n]ode .*dist/server/index|[t]s-node server/index|[t]sx server/index' || true

echo
echo "=== SERVER LISTEN CONFIG ==="
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  -E 'listen\(|PORT|project.?registry' \
  server db routes 2>/dev/null | head -n 220 || true

echo
echo "DIAGNOSIS_ONLY=YES"
echo "PRODUCTION_ROUTE_ACTIVATION_ATTEMPTED=NO"
