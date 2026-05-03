#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "PHASE 70B OPERATOR DIAGNOSTICS"
echo "--------------------------------"

echo "Running operator health verification..."
bash scripts/_local/phase70a_verify_operator_health.sh

echo ""
echo "Generating diagnostics report..."
bash scripts/_local/phase70b_generate_diagnostics_report.sh

echo ""
echo "PHASE 70B DIAGNOSTICS COMPLETE"
