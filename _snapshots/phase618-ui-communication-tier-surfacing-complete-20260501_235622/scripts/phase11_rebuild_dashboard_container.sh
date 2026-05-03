#!/usr/bin/env bash
set -euo pipefail

# Phase 11 – Rebuild & restart dashboard container after server.mjs changes
# This script makes sure the container is running the latest stubbed endpoints.

cd "$(dirname "$0")/.."

echo "🔹 Rebuilding dashboard container image with no cache..."
docker-compose build --no-cache

echo
echo "🔹 Restarting containers (down, then up -d)..."
docker-compose down
docker-compose up -d

echo
echo "🔹 Showing recent logs (last 50 lines)..."
docker-compose logs --tail=50

echo
echo "✅ phase11_rebuild_dashboard_container.sh complete."
echo "   Next, run:"
echo "     scripts/phase11_delegate_task_curl.sh"
echo "   and then, using the returned id:"
echo "     scripts/phase11_complete_task_curl.sh <TASK_ID>"
