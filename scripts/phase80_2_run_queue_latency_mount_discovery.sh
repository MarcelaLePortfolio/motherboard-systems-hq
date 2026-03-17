#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

./scripts/phase80_2_find_queue_latency_mount.sh

LATEST_REPORT="$(ls -1t PHASE80_2_QUEUE_LATENCY_MOUNT_DISCOVERY_*.md | head -n 1)"

echo
echo "========================================"
echo "LATEST MOUNT DISCOVERY REPORT"
echo "========================================"
echo "${LATEST_REPORT}"
echo
sed -n '1,240p' "${LATEST_REPORT}"
