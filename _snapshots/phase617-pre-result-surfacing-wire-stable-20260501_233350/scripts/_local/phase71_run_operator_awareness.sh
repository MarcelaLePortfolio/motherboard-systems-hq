#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "PHASE 71 RUN OPERATOR AWARENESS"
echo "-------------------------------"

echo "Running operator signals pipeline..."
bash scripts/_local/phase70c_run_operator_signals.sh

echo ""
echo "Running operator awareness..."
bash scripts/_local/phase71_operator_awareness.sh

echo ""
echo "PHASE 71 AWARENESS RUN COMPLETE"
