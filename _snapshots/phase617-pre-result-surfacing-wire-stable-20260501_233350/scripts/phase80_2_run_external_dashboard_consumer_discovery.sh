#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

./scripts/phase80_2_find_external_dashboard_consumers.sh

LATEST_REPORT="$(ls -1t PHASE80_2_EXTERNAL_DASHBOARD_CONSUMER_DISCOVERY_*.md | head -n 1)"

echo
echo "========================================"
echo "LATEST EXTERNAL DASHBOARD CONSUMER REPORT"
echo "========================================"
echo "${LATEST_REPORT}"
echo
sed -n '1,260p' "${LATEST_REPORT}"
