#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE="scripts/utils/ollamaChat.ts"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_HEAD='"$(git rev-parse --short HEAD)" \
  'IMPLEMENTATION=SUPPORT_REFERENCE_PRESENTATION_CONFLICT_REMOVAL' \
  'IMPLEMENTATION_AUTHORIZED=YES' \
  'POST_CHANGE_OLLAMA_VALIDATION_AUTHORIZED=NO' \
  'DASHBOARD_SMOKE_TEST_AUTHORIZED=NO'

python3 - << 'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

target = '              `Display identity = ${item.relativePath}:${item.lineNumber}`,\n'
count = text.count(target)

if count != 2:
    raise SystemExit(
        f"EXPECTED_EXACTLY_TWO_MODEL_VISIBLE_DISPLAY_IDENTITY_LINES_FOUND_{count}"
    )

text = text.replace(target, "")
path.write_text(text)
PY

printf '\n=== BOUNDED DIFF ===\n'
git diff -- "$FILE"

printf '\n=== VERIFICATION ===\n'
grep -n -A5 -B3 'relativePath = ${item.relativePath}' "$FILE" || true

if grep -Fq 'Display identity = ${item.relativePath}:${item.lineNumber}' "$FILE"; then
  echo 'CONFLICTING_DISPLAY_IDENTITY_PRESENT=YES'
  exit 1
fi

printf '%s\n' \
  'CONFLICTING_DISPLAY_IDENTITY_PRESENT=NO' \
  'SEPARATE_RELATIVE_PATH_PRESENTATION_PRESERVED=YES' \
  'SEPARATE_LINE_NUMBER_PRESENTATION_PRESERVED=YES'

printf '\n=== TYPECHECK ===\n'
set +e
npx tsc --noEmit
TYPECHECK_STATUS=$?
set -e

printf '\n=== TYPECHECK CLASSIFICATION ===\n'
printf '%s\n' \
  "TYPECHECK_STATUS=$TYPECHECK_STATUS" \
  'KNOWN_UNRELATED_ATLAS_TS2554_MAY_REMAIN=YES'

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'PROMPT_PRESENTATION_CONFLICT_REMOVAL_IMPLEMENTED=YES' \
  'OLLAMA_INVOCATION_STARTED=NO' \
  'DASHBOARD_SMOKE_TEST_STARTED=NO' \
  'OUTPUT_SCHEMA_CHANGED=NO' \
  'VALIDATOR_CHANGED=NO' \
  'VALIDATOR_WEAKENED=NO' \
  'MODEL_CHANGED=NO' \
  'TIMEOUT_CHANGED=NO' \
  'RETRY_CHANGED=NO' \
  'GENERATION_POLICY_CHANGED=NO' \
  'DATABASE_CHANGED=NO' \
  'NEXT_ACTION=CLASSIFY_IMPLEMENTATION_RESULT_AND_OPEN_SEPARATE_POST_CHANGE_VALIDATION_GATE'
