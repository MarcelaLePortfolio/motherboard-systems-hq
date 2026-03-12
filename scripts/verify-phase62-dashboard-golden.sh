#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "PHASE 62 DASHBOARD GOLDEN VERIFY"
echo "--------------------------------"

scripts/verify-phase62-layout-contract.sh

echo ""

scripts/verify-phase62b-metric-bindings.sh

echo ""
echo "PHASE 62 DASHBOARD GOLDEN STATE VERIFIED"
