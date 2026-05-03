#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65 — Pre-Commit Protection Gate"

echo ""
echo "Running protected file guard..."
bash scripts/_local/phase65_protected_file_guard.sh

echo ""
echo "Running layout drift guard..."
bash scripts/_local/phase65_layout_drift_guard.sh

echo ""
echo "Running protection checklist..."
bash scripts/_local/phase65_protection_checklist.sh

echo ""
echo "PROTECTION GATE PASS"
