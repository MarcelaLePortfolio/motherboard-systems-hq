#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SOURCE="scripts/run-dashboard-generation-control-comparison.ts"
TMP="scripts/.run-dashboard-support-reference-single-diagnostic.ts"
RESULT="docs/checkpoints/MATILDA_UI_503_SUPPORT_REFERENCE_SINGLE_DIAGNOSTIC_RESULT.txt"

cp "$SOURCE" "$TMP"

python3 - << 'PY'
from pathlib import Path

path = Path("scripts/.run-dashboard-support-reference-single-diagnostic.ts")
text = path.read_text()
text = text.replace("const UNSEEDED_RUNS = 10;", "const UNSEEDED_RUNS = 1;", 1)
text = text.replace("const CONTROLLED_RUNS = 10;", "const CONTROLLED_RUNS = 0;", 1)
path.write_text(text)
PY

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=a026adb5' \
  'ISSUE_RESOLVED=NO' \
  'DIAGNOSTIC_OLLAMA_INVOCATION_AUTHORIZED=YES' \
  'AUTHORIZED_INVOCATION_COUNT=1' \
  'RETRY_COUNT=0' \
  'PRODUCTION_CHANGE=NO' \
  'DATABASE_WRITE=NO' \
  'VALIDATOR_CHANGE=NO' \
  'PROMPT_CHANGE=NO' \
  'MODEL_CHANGE=NO' \
  'GENERATION_POLICY_CHANGE=NO'

set +e
npx tsx "$TMP" 2>&1 | tee "$RESULT"
RUN_STATUS=${PIPESTATUS[0]}
set -e

rm -f "$TMP"

printf '\n=== CAPTURED SUPPORT REFERENCES ===\n'
grep -n -A40 -B8 \
  '"parsedSupportReferences"\|"failureClass"\|"errorMessage"' \
  "$RESULT" || true

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  "RUN_STATUS=$RUN_STATUS" \
  'AUTHORIZED_INVOCATIONS_USED=1_OF_1' \
  'ADDITIONAL_OLLAMA_INVOCATIONS_AUTHORIZED=NO' \
  'PRODUCTION_FIX_AUTHORIZED=NO' \
  'NEXT_ACTION=CLASSIFY_EXACT_MODEL_AUTHORED_REFERENCE_MISMATCH'

git status --short
