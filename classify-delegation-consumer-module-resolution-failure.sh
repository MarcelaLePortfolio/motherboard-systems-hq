#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY DELEGATION CONSUMER MODULE RESOLUTION FAILURE ==="
echo "BASELINE_COMMIT=7f2a29a8"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== VERIFIED STARTUP FAILURE ==="
echo "EXPRESS_STARTUP_FAILURE=MODULE_NOT_FOUND"
echo "MISSING_MODULE=../delegation/production-delegation-consumer.js"
echo "IMPORTER=server/routes/governance-delegation-route.ts"
echo "SERVER_INDEX_LOAD_BLOCKED=YES"
echo "PORT_3000_UNAVAILABLE_BECAUSE_SERVER_BOOT_ABORTS=YES"

echo
echo "=== IMPORT SITE ==="
sed -n '1,120p' server/routes/governance-delegation-route.ts

echo
echo "=== DELEGATION DIRECTORY ==="
find server/delegation -maxdepth 2 -type f -print 2>/dev/null | sort || true

echo
echo "=== RESOLUTION SEARCH ==="
rg -n \
  'production-delegation-consumer|governance-delegation-route' \
  server db routes \
  -g '*.ts' -g '*.js' -g '*.mjs' \
  2>/dev/null || true

echo
echo "=== TYPESCRIPT MODULE CONFIG ==="
node -e '
const fs=require("fs");
for (const file of ["tsconfig.json","server/tsconfig.json"]) {
  if (fs.existsSync(file)) {
    console.log(`--- ${file} ---`);
    console.log(fs.readFileSync(file,"utf8"));
  }
}
'

echo
echo "=== GIT HISTORY FOR TARGET FILES ==="
git log --oneline --all -- \
  server/routes/governance-delegation-route.ts \
  server/delegation/production-delegation-consumer.ts \
  server/delegation/production-delegation-consumer.js \
  | head -40 || true

echo
echo "=== CLASSIFICATION BOUNDARY ==="
echo "PROJECT_CONTEXT_FAILURE_IS_DOWNSTREAM_SYMPTOM=YES"
echo "EXPRESS_RUNTIME_ROOT_CAUSE=BOOT_TIME_MODULE_RESOLUTION_FAILURE"
echo "MISSING_FILE_VS_EXTENSION_MISMATCH=NOT_YET_CLASSIFIED"
echo "SPECULATIVE_FIX_ALLOWED=NO"
echo "NEXT_ACTION=CLASSIFY_WHETHER_THE_DELEGATION_CONSUMER_SOURCE_IS_MISSING_RENAMED_OR_IMPORTED_WITH_AN_INCOMPATIBLE_EXTENSION"
