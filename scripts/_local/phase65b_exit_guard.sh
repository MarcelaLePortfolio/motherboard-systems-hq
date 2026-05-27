#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65B — Exit Guard"
echo

echo "1 Running final ownership verification..."
bash scripts/_local/phase65b_verify_final_metric_ownership_map.sh
echo

echo "2 Running metric-agents ownership guard..."
bash scripts/_local/phase65b_guard_metric_agents_ownership.sh
echo

echo "3 Running all-current-metric-owner guard..."
bash scripts/_local/phase65b_guard_all_current_metric_owners.sh
echo

echo "4 Running protection gate..."
bash scripts/_local/phase65_pre_commit_protection_gate.sh
echo

echo "PHASE 65B EXIT GUARD PASS"
