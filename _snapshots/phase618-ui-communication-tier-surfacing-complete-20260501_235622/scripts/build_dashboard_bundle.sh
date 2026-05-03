#!/usr/bin/env bash
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
