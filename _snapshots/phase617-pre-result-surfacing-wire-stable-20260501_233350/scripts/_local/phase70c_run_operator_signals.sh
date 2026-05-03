#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "PHASE 70C RUN OPERATOR SIGNALS"
echo "------------------------------"

echo "Running diagnostics pipeline..."
bash scripts/_local/phase70b_operator_diagnostics.sh

echo ""
echo "Emitting operator signals..."
bash scripts/_local/phase70c_operator_signals.sh

echo ""
echo "PHASE 70C SIGNAL RUN COMPLETE"
