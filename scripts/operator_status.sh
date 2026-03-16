#!/usr/bin/env bash
set -euo pipefail

echo ""
echo "MOTHERBOARD SYSTEMS HQ — OPERATOR STATUS"
echo "========================================"

bash scripts/_local/phase71_run_operator_awareness.sh

echo ""
echo "STATUS_CHECK_COMPLETE"
