#!/usr/bin/env bash
set -euo pipefail

echo "Scanning governance consumption boundaries..."

echo ""
echo "=== AUTHORIZATION GATES ==="
grep -R "authorizationGate" src || true

echo ""
echo "=== REGISTRY EXPORT ==="
grep -R "registryExport" src || true

echo ""
echo "=== POLICY GATES ==="
grep -R "policyGate" src || true

echo ""
echo "=== SITUATION SUMMARY ==="
grep -R "situationSummary" src || true

echo ""
echo "Boundary scan complete."
