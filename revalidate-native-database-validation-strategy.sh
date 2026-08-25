#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== REVALIDATE NATIVE DATABASE VALIDATION STRATEGY ==="
echo "BASELINE_COMMIT=ccc40a24"
echo "CLOSED_MILESTONE=MISSION_CONTROL_PROJECT_CONTEXT_ALIGNMENT"
echo "CANDIDATE=NATIVE_DATABASE_VALIDATION_STRATEGY"
echo "SUCCESSOR_MILESTONE=NOT_YET_ESTABLISHED"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== CANONICAL FINDING ==="
sed -n '1,120p' docs/native-database-validation-strategy-finding.md

echo
echo "=== RELATED CURRENT BOUNDARY ==="
if [[ -f docs/native-runtime-validation-decision-corridor.md ]]; then
  sed -n '1,140p' docs/native-runtime-validation-decision-corridor.md
fi

echo
echo "=== CURRENT RUNTIME EVIDENCE ==="
rg -n \
  'sqlite|better-sqlite3|database|DB_PATH|DATABASE_URL|native runtime|native database|validation strategy|lifecycle entry' \
  db server routes package.json \
  -g '*.ts' -g '*.json' \
  2>/dev/null || true

echo
echo "=== REVALIDATION BOUNDARY ==="
echo "HISTORICAL_FINDING_AUTOMATICALLY_GOVERNS_CURRENT_BASELINE=NO"
echo "CURRENT_RUNTIME_ALIGNMENT_MUST_BE_ESTABLISHED=YES"
echo "SUCCESSOR_SELECTION_AUTHORIZED=NO"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_WHETHER_NATIVE_DATABASE_VALIDATION_STRATEGY_REMAINS_A_CURRENT_REQUIRED_CAPABILITY_BOUNDARY"
