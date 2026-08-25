#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY SECOND DEV IMPORT RESOLUTION FAILURE ==="
echo "BASELINE_COMMIT=280b28b5"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== VERIFIED FIRST FIX RESULT ==="
echo "FIRST_IMPORT_MISMATCH_FIXED=YES"
echo "SERVER_ADVANCED_TO_NEXT_MODULE_LOAD=YES"
echo "NEW_FAILURE_MODULE=../../db/governance-runtime.js"
echo "NEW_FAILURE_IMPORTER=server/delegation/production-delegation-consumer.ts"

echo
echo "=== IMPORT SITE ==="
sed -n '1,100p' server/delegation/production-delegation-consumer.ts

echo
echo "=== TARGET SOURCE STATE ==="
find db -maxdepth 2 -type f \
  \( -name 'governance-runtime.ts' -o -name 'governance-runtime.js' -o -name 'governance-runtime.mjs' \) \
  -print | sort || true

echo
echo "=== RELATED SOURCE IMPORTS ==="
rg -n \
  'governance-runtime(\.js)?|from "\.\./\.\./db/' \
  server db routes \
  -g '*.ts' -g '*.js' -g '*.mjs' \
  2>/dev/null || true

echo
echo "=== COMPILED OUTPUT CHECK ==="
find dist/db dist/server \
  -maxdepth 3 -type f \
  -name 'governance-runtime.js' \
  -print 2>/dev/null || true

echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "FIRST_FIX_ROLLBACK_REQUIRED=NO_EVIDENCE"
echo "FIRST_FIX_EXPOSED_NEXT_PREEXISTING_BOOT_BLOCKER=YES"
echo "SECOND_FAILURE_SAME_GENERAL_CLASS=LIKELY_IMPORT_EXTENSION_MISMATCH"
echo "SECOND_FAILURE_CONFIRMED_FIX=NOT_YET_AUTHORIZED"
echo "THREE_FAILED_HYPOTHESIS_COUNT=NOT_REACHED"
echo "SPECULATIVE_LAYERING_ALLOWED=NO"
echo "NEXT_ACTION=CLASSIFY_EXACT_governance-runtime_SOURCE_AND_IMPORT_RESOLUTION_BEFORE_AUTHORIZING_SECOND_NARROW_FIX"
