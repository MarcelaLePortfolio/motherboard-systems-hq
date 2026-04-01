#!/usr/bin/env bash
set -euo pipefail

echo "Tracing eligibility signal consumers..."

echo ""
echo "=== handoffEligible consumers ==="
grep -R "handoffEligible" src || true

echo ""
echo "=== authorizationEligible consumers ==="
grep -R "authorizationEligible" src | grep -v governance || true

echo ""
echo "=== eligibleForExplicitLiveWiring consumers ==="
grep -R "eligibleForExplicitLiveWiring" src | grep -v governance || true

echo ""
echo "Execution consumption trace complete."
