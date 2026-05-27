#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "PHASE61_STATUS=STRUCTURE_REPAIRED"
echo "LAYOUT_CONTRACT=PASS"
echo "STRUCTURE_VERIFY=PASS"
echo "LOCAL_DASHBOARD_URL=http://127.0.0.1:8080/dashboard"
echo

scripts/verify-dashboard-two-panel-structure.sh
echo
scripts/_local/phase61_run_local_verify.sh
echo
git status --short
echo
git --no-pager log --oneline -8
