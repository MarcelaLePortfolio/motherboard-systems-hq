#!/usr/bin/env bash
set -euo pipefail

echo "PHASE 65 — Protection Completeness Checklist"

echo ""
echo "1 Checking golden anchor exists..."
git rev-parse v63.0-telemetry-integration-golden >/dev/null
echo "OK"

echo ""
echo "2 Running layout drift guard..."
bash scripts/_local/phase65_layout_drift_guard.sh

echo ""
echo "3 Verifying protected registry exists..."
test -f docs/protection/PHASE65_PROTECTED_SURFACE_REGISTRY.md
echo "OK"

echo ""
echo "4 Verifying dashboard structure file exists..."
test -f public/dashboard.html
echo "OK"

echo ""
echo "5 Verifying CSS structure file exists..."
test -f public/css/dashboard.css
echo "OK"

echo ""
echo "PROTECTION CHECKLIST PASS"
