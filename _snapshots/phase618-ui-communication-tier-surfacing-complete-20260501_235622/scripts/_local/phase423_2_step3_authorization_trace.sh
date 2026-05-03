#!/usr/bin/env bash
set -euo pipefail

echo "Tracing authorization eligibility influence..."

echo ""
echo "=== authorizationEligible ==="
grep -R "authorizationEligible" src || true

echo ""
echo "=== readiness ==="
grep -R "readiness" src || true

echo ""
echo "=== execution eligibility ==="
grep -R "eligible" src || true

echo ""
echo "Trace complete."
