#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

git restore public/dashboard.html

echo "=== ATLAS ID LOCATIONS ==="
grep -nE 'phase61-atlas-band|atlas-status-card|Atlas Subsystem Status|phase61-workspace-grid' public/dashboard.html || true
echo

echo "=== DASHBOARD AROUND WORKSPACE/ATLAS REGION ==="
nl -ba public/dashboard.html | sed -n '200,360p'
