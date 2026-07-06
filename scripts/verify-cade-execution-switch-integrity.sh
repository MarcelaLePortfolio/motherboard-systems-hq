
#!/usr/bin/env bash

set -euo pipefail

echo "=== Cade Execution Switch Integrity Check ==="

echo ""

echo "1. Checking for direct EXECUTABLE assignments..."

grep -Rni "EXECUTABLE" server docs | grep -v "switchEvaluator" || true

echo ""

echo "2. Checking for any direct execution_authorized mutations outside approval/switch layers..."

grep -Rni "execution_authorized\s*=" server | grep -v "execution-approval-gate" | grep -v "matilda-execution-switch" || true

echo ""

echo "3. Verifying switch evaluator exists and is wired..."

test -f server/execution/matilda-execution-switch-evaluator.ts && echo "OK: switch evaluator present" || echo "MISSING: switch evaluator"

echo ""

echo "4. Verifying approval gate integration..."

grep -Rni "execution_switch_state" server/execution/execution-approval-gate.mjs && echo "OK: switch wired into approval gate" || echo "MISSING: switch wiring"

echo ""

echo "=== Integrity Check Complete ==="

