#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$PROJECT_ROOT"

echo "==== docker ps (all) ===="
docker ps -a

echo
echo "==== logs: motherboard_systems_hq-dashboard-1 ===="
docker logs motherboard_systems_hq-dashboard-1 --tail=200 || echo "No logs for dashboard container"
