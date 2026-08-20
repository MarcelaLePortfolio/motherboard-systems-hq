#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE="scripts/utils/ollamaChat.ts"

python3 - << 'PY'
from pathlib import Path

path = Path("scripts/utils/ollamaChat.ts")
text = path.read_text()

old = """const OLLAMA_CHAT_TIMEOUT_MS = Number(
  process.env.OLLAMA_CHAT_TIMEOUT_MS ?? 60_000,
);"""

new = """const OLLAMA_CHAT_TIMEOUT_MS = Number(
  process.env.OLLAMA_CHAT_TIMEOUT_MS ?? 90_000,
);"""

if old not in text:
    raise SystemExit("OLLAMA_TIMEOUT_ANCHOR_NOT_FOUND")

text = text.replace(old, new, 1)
path.write_text(text)
PY

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=ed0938f7' \
  'IMPLEMENTATION=OLLAMA_CLIENT_TIMEOUT_ONLY' \
  'IMPLEMENTATION_AUTHORIZED=YES' \
  'ROLLBACK_CHECKPOINT=1e4b7e7b' \
  'OLD_TIMEOUT_MS=60000' \
  'NEW_TIMEOUT_MS=90000' \
  'POST_CHANGE_OLLAMA_VALIDATION_AUTHORIZED=NO' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'PROMPT_CHANGE=NO' \
  'VALIDATOR_CHANGE=NO' \
  'MODEL_CHANGE=NO' \
  'RETRY_CHANGE=NO' \
  'GENERATION_POLICY_CHANGE=NO' \
  'DATABASE_CHANGE=NO'

printf '\n=== DIFF ===\n'
git diff -- "$FILE"

printf '\n=== TIMEOUT VERIFICATION ===\n'
grep -n -A3 -B1 'OLLAMA_CHAT_TIMEOUT_MS' "$FILE"

printf '\n=== TYPECHECK ===\n'
set +e
npx tsc --noEmit
TYPECHECK_STATUS=$?
set -e

printf '\n=== TYPECHECK CLASSIFICATION ===\n'
printf '%s\n' \
  "TYPECHECK_STATUS=$TYPECHECK_STATUS" \
  'KNOWN_UNRELATED_ATLAS_TS2554_MAY_REMAIN=YES' \
  'TIMEOUT_IMPLEMENTATION_REQUIRES_NO_SCHEMA_OR_TYPE_CHANGE=YES'

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'TIMEOUT_IMPLEMENTED=YES' \
  'OLLAMA_VALIDATION_RUN_STARTED=NO' \
  'PRODUCTION_PROMPT_CHANGED=NO' \
  'VALIDATOR_CHANGED=NO' \
  'VALIDATOR_WEAKENED=NO' \
  'MODEL_CHANGED=NO' \
  'RETRY_POLICY_CHANGED=NO' \
  'GENERATION_POLICY_CHANGED=NO' \
  'NEXT_ACTION=CLASSIFY_TIMEOUT_IMPLEMENTATION_RESULT_AND_OPEN_SEPARATE_POST_CHANGE_VALIDATION_GATE'

git status --short
