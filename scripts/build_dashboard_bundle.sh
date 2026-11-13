#!/usr/bin/env bash

# Dashboard Protection Corridor 3: default-deny historical entrypoint.
if [ "${MOTHERBOARD_ALLOW_LEGACY_DASHBOARD_RESTORE:-}" != "I_ACKNOWLEDGE_LEGACY_DASHBOARD_RESTORE" ]; then
  echo "BLOCKED: Legacy dashboard restoration is disabled." >&2
  echo "Authoritative dashboard: client/dist/index.html" >&2
  exit 78
fi
set -euo pipefail
trap 'echo "[build_dashboard_bundle] FAIL line= cmd= rc=0" >&2' ERR

# Root of the project
cd "$(dirname "$0")/.."

echo "▶ Building dashboard bundle…"
npm run build:dashboard-bundle

echo "▶ Rebuilding containers…"
docker compose build

echo "▶ Restarting containers…"
docker compose up -d

echo "✅ Dashboard bundle build + container restart complete."
