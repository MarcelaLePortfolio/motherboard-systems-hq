#!/usr/bin/env bash
set -euo pipefail

echo "=== entrypoint consumers ==="
grep -R "runConsumptionRegistryEnforcementEntrypoint(" -n . || true

echo ""
echo "=== result shape consumers ==="
grep -R "ConsumptionRegistryEnforcementEntrypointResult" -n src . || true

echo ""
echo "=== ok/view field consumers ==="
grep -R "view.ok" -n src . || true
grep -R "\.view" -n src/cognition src/routes src/dashboard . || true
