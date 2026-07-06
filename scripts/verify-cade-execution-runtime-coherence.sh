
#!/usr/bin/env bash

set -euo pipefail

echo "=== Cade Execution Runtime Coherence Check ==="

echo ""

echo "1. Checking switch evaluator logic consistency..."

grep -Rni "isExecutable\|EXECUTABLE\|plan_review_ready\|preview_confirmed\|execution_authorized" \

server/execution/matilda-execution-switch-evaluator.ts

echo ""

echo "2. Checking approval gate output fields..."

grep -Rni "execution_switch_state\|execution_switch_executable" \

server/execution/execution-approval-gate.mjs

echo ""

echo "3. Checking for conflicting execution state sources..."

grep -Rni "execution_authorized.*true\|execution_authorized.*false" server \

| grep -v "matilda-execution-switch" \

| grep -v "approval-gate" || true

echo ""

echo "4. Checking DB source of truth for execution flags..."

grep -Rni "execution_authorized" db | head -50

echo ""

echo "=== Coherence Check Complete ==="

