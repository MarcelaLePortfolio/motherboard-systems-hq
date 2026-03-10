#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

echo "=== CURRENT SOURCE ATLAS REGION ==="
nl -ba public/dashboard.html | sed -n '320,355p'
echo
echo "=== LIVE DASHBOARD HTML ATLAS MARKERS ==="
curl -fsS http://127.0.0.1:8080/dashboard | grep -nE 'phase61-atlas-band|atlas-status-card|Atlas Subsystem Status|phase61-workspace-grid' || true
