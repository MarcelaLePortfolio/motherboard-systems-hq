#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "PHASE 63 TELEMETRY BASELINE VERIFY"
echo "----------------------------------"

scripts/verify-phase62-dashboard-golden.sh

echo ""
echo "PHASE 63 BASELINE VERIFIED"
