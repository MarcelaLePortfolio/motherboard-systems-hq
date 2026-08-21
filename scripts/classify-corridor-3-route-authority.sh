#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n============================================================\n'
printf '🚦 CORRIDOR 3 · AUTHORITATIVE PACKAGE LINEAGE RECONCILIATION\n'
printf 'STATUS: 🟢 ACTIVE · ROUTE AUTHORITY CHECK\n'
printf '============================================================\n\n'

printf '%s\n' \
'DR_CHECKPOINT=20260820_170737' \
'CLASSIFICATION_ONLY=YES' \
'IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== ACTIVE SERVER ENTRY POINTS ===\n'
find server routes -maxdepth 2 -type f \
  \( -name 'index.ts' -o -name 'server.ts' -o -name 'app.ts' -o -name 'routes.ts' \) \
  -print | sort

printf '\n=== MATILDA GOVERNANCE ROUTE IMPORTS / MOUNTS ===\n'
grep -Rni \
  --exclude='*.test.ts' \
  --exclude='*.bak' \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'matilda-(delegation|governance-validation|envelope|routing|assignment)-route|matildaDelegation|matildaGovernance|matildaEnvelope|matildaRouting|matildaAssignment' \
  server routes ./*.ts 2>/dev/null || true

printf '\n=== DB/MAIN GOVERNANCE ROUTE IMPORTS / MOUNTS ===\n'
grep -Rni \
  --exclude='*.test.ts' \
  --exclude='*.bak' \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'governance-(package|delegation|validation|envelope-gate|envelope)-route|createGovernance(Package|Delegation|ValidationResult|EnvelopeGate|Envelope)' \
  server routes ./*.ts 2>/dev/null || true

printf '\n=== EXPRESS ROUTER REGISTRATION SURFACE ===\n'
grep -Rni \
  --exclude='*.test.ts' \
  --exclude='*.bak' \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'app\.use|router\.use|app\.post|router\.post' \
  server routes ./*.ts 2>/dev/null | head -400 || true

printf '\n=== CLASSIFICATION TARGET ===\n'
printf '%s\n' \
'IF_MATILDA_ROUTES_UNMOUNTED=CLASSIFY_AS_HISTORICAL_PARALLEL_RUNTIME' \
'IF_MATILDA_ROUTES_MOUNTED=CLASSIFY_AS_LIVE_PARALLEL_RUNTIME_AND_STOP_FOR_SCOPE_REASSESSMENT' \
'DO_NOT_DELETE_OR_MIGRATE_ANYTHING=YES' \
'IMPLEMENTATION_AUTHORIZED=NO' \
'PRODUCTION_CHANGE=NONE'
