#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== RECONCILE RUNNING API ORIGIN FOR PROJECT CONTEXT ==="
echo "BASELINE_COMMIT=2845fa2b"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== PACKAGE / DEV RUNTIME ==="
cat package.json | sed -n '1,140p'

echo
echo "=== VITE / CLIENT ORIGIN CONFIG ==="
rg -n -C 8 \
  'proxy|3000|5173|server:|VITE_|/api' \
  vite.config.* client package.json \
  2>/dev/null || true

echo
echo "=== SERVER LISTEN CONFIG ==="
rg -n -C 8 \
  'PORT|listen\\(|3000|app.listen' \
  server/index.ts package.json \
  2>/dev/null || true

echo
echo "=== LISTENING PORTS ==="
(lsof -nP -iTCP -sTCP:LISTEN | rg 'node|vite|3000|5173|4173' || true)

echo
echo "=== PROCESS SNAPSHOT ==="
(ps aux | rg 'vite|tsx|node .*server|npm|pnpm' | rg -v 'rg ' || true)

echo
echo "=== HTTP PROBES ==="
for url in \
  http://127.0.0.1:3000/api/projects/registry \
  http://127.0.0.1:5173/api/projects/registry \
  http://127.0.0.1:4173/api/projects/registry
do
  code="$(curl -sS -o /tmp/project-registry-probe.$$ -w '%{http_code}' "$url" || true)"
  echo "${url} -> ${code}"
  if [[ -s /tmp/project-registry-probe.$$ ]]; then
    head -c 500 /tmp/project-registry-probe.$$
    echo
  fi
done
rm -f /tmp/project-registry-probe.$$

echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "PERSISTENCE_AND_REGISTRY_STATE_ALREADY_VERIFIED=HEALTHY"
echo "CURRENT_QUESTION=WHICH_ORIGIN_THE_UI_IS_RUNNING_ON_AND_WHETHER_/api_IS_PROXIED_TO_EXPRESS"
echo "CLIENT_IMPLEMENTATION_CHANGE_AUTHORIZED=NO"
echo "SERVER_IMPLEMENTATION_CHANGE_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_DEV_SERVER_ORIGIN_PROXY_OR_PROCESS_STARTUP_MISMATCH_FROM_RUNTIME_EVIDENCE"
