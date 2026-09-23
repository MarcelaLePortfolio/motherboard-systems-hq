#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="43ae50cde"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

printf '\n=== VALIDATION → ENVELOPE GATE INSPECTION ===\n'
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "CURRENT_STEP=INSPECTION_ONLY"
echo "LIVE_ENVELOPE_GATE_INVOCATION=NO"
echo "LIVE_GOVERNANCE_DATA_MUTATION=NO"
echo "AUTOMATIC_TRANSITION=NO"
echo "AUTOMATIC_ENVELOPE_CREATION=NO"
echo "EXECUTION_AUTHORITY=NO"
echo "NEW_AUTHORITY=NO"

printf '\n=== ENVELOPE / GATE FILE DISCOVERY ===\n'
find server db client/src -type f \
  \( -iname '*envelope*' -o -iname '*gate*' -o -iname '*validation*' \) \
  -print | sort

printf '\n=== ENVELOPE / GATE SYMBOL REFERENCES ===\n'
grep -RniE \
  'envelope.?gate|execution.?envelope|governance.?envelope|validation_result_id|validation_status' \
  server db client/src \
  --exclude-dir=node_modules \
  | head -n 420 || true

printf '\n=== SERVER ROUTE MOUNTS ===\n'
grep -nE \
  'envelope|gate|validation|app\.use|router' \
  server/index.ts \
  | head -n 240 || true

printf '\n=== GOVERNANCE LIFECYCLE ENFORCEMENT ===\n'
sed -n '1,320p' db/governance-lifecycle-enforcement.ts

printf '\n=== VALIDATION PERSISTENCE / RESULT SHAPE ===\n'
grep -RniE \
  'createGovernanceValidationResult|CreatedGovernanceValidationResult|governance_validation_results' \
  db server \
  --exclude-dir=node_modules \
  | head -n 300 || true

printf '\n=== EXISTING ENVELOPE ENTRY POINTS / CONSUMERS ===\n'
for f in $(find server db -type f | grep -Ei 'envelope|gate' | sort); do
  echo
  echo "===== $f ====="
  sed -n '1,280p' "$f"
done

printf '\n=== WORKTREE PRESERVATION ===\n'
git status --short

printf '\nVALIDATION_TO_ENVELOPE_GATE_RUNTIME_INSPECTION=COMPLETE\n'
