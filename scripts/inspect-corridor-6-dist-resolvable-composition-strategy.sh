#!/usr/bin/env bash
set -euo pipefail

EXPECTED_HEAD="3850476ecb464e157d13b361d38488a96615079c"
CURRENT_HEAD="$(git rev-parse HEAD)"

echo "EXPECTED_HEAD=${EXPECTED_HEAD}"
echo "CURRENT_HEAD=${CURRENT_HEAD}"
test "${CURRENT_HEAD}" = "${EXPECTED_HEAD}"

echo "=== BUILD CONFIG ==="
cat tsconfig.json

echo
echo "=== EXECUTION SOURCE FILES ==="
find server/execution -maxdepth 1 -type f \
  \( -name '*.ts' -o -name '*.mjs' -o -name '*.js' \) \
  -print | sort

echo
echo "=== RELEVANT IMPORTS ==="
grep -RIn \
  -e 'execution-approval-gate' \
  -e 'matilda-execution-switch-evaluator' \
  -e 'production-governance-execution-composition' \
  -e 'cade-governed-commit-adapter' \
  -e 'cade-governed-push-adapter' \
  server db \
  --include='*.ts' --include='*.mjs' --include='*.js' || true

echo
echo "=== BUILD OUTPUT ==="
npm run build

find dist/server/execution -maxdepth 1 -type f \
  \( -name '*.js' -o -name '*.mjs' \) \
  -print | sort

echo
echo "=== DIST-RESOLUTION CHECK ==="
for f in \
  dist/server/execution/matilda-execution-switch-evaluator.js \
  dist/server/execution/cade-governed-commit-adapter.js \
  dist/server/execution/cade-governed-push-adapter.js \
  dist/server/execution/production-execution-entry-point.js
do
  if [[ -f "$f" ]]; then
    echo "$f=PASS"
  else
    echo "$f=MISSING"
  fi
done

for f in \
  dist/server/execution/execution-approval-gate.mjs \
  dist/server/execution/production-governance-execution-composition.mjs
do
  if [[ -f "$f" ]]; then
    echo "$f=PASS"
  else
    echo "$f=MISSING"
  fi
done

echo
echo "CLASSIFICATION_MODE=COLLABORATION_ONLY"
echo "PRODUCTION_CHANGE=NONE"
echo "CORRIDOR_6_STATUS=ACTIVE"
echo "PHASE_1_STATUS=ACTIVE"
