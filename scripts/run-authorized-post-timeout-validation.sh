#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SOURCE="scripts/run-single-post-fix-validation.sh"
ORIGINAL_RESULT="docs/checkpoints/MATILDA_UI_503_POST_FIX_SINGLE_VALIDATION_RESULT.txt"
POST_TIMEOUT_RESULT="docs/checkpoints/MATILDA_UI_503_POST_TIMEOUT_SINGLE_VALIDATION_RESULT.txt"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=95da7eda' \
  'ACTION=RUN_AUTHORIZED_POST_TIMEOUT_VALIDATION' \
  'VALIDATION_AUTHORIZATION_REMAINS_AVAILABLE=YES' \
  'AUTHORIZED_INVOCATION_COUNT=1' \
  'CURRENT_TIMEOUT_MS=90000' \
  'DASHBOARD_VISIBLE_SMOKE_TEST_AUTHORIZED=NO' \
  'ADDITIONAL_RETRY_AUTHORIZED=NO'

if [[ ! -x "$SOURCE" ]]; then
  echo 'EXISTING_SINGLE_VALIDATION_RUNNER_NOT_EXECUTABLE'
  exit 1
fi

rm -f "$ORIGINAL_RESULT"

set +e
"$SOURCE"
RUN_STATUS=$?
set -e

if [[ -f "$ORIGINAL_RESULT" ]]; then
  cp "$ORIGINAL_RESULT" "$POST_TIMEOUT_RESULT"
else
  printf '%s\n' \
    'POST_TIMEOUT_RESULT_CAPTURE=NOT_FOUND' \
    "RUN_STATUS=$RUN_STATUS" \
    > "$POST_TIMEOUT_RESULT"
fi

printf '\n=== POST-TIMEOUT VALIDATION RESULT ===\n'
cat "$POST_TIMEOUT_RESULT"

printf '\n=== POST-TIMEOUT CLASSIFICATION ===\n'
python3 - << 'PY'
from pathlib import Path
import json
import re

path = Path("docs/checkpoints/MATILDA_UI_503_POST_TIMEOUT_SINGLE_VALIDATION_RESULT.txt")
text = path.read_text()

print("AUTHORIZED_OLLAMA_INVOCATION_CONSUMED=YES")
print("ADDITIONAL_OLLAMA_INVOCATIONS_AUTHORIZED=NO")

if "Ollama chat request timed out." in text or '"failureClass": "OLLAMA_TIMEOUT"' in text:
    print("POST_TIMEOUT_RESULT=OLLAMA_TIMEOUT")
    print("NINETY_SECOND_TIMEOUT_VALIDATED=NO")
    print("SUPPORT_REFERENCE_FIX_VALIDATED=NO")
    raise SystemExit(0)

match = re.search(r'\{\n\s*"arm": "UNSEEDED".*?\n\}', text, re.S)
if not match:
    print("POST_TIMEOUT_RESULT=NO_PARSEABLE_RUN_RECORD")
    print("NINETY_SECOND_TIMEOUT_VALIDATED=INDETERMINATE")
    print("SUPPORT_REFERENCE_FIX_VALIDATED=INDETERMINATE")
    raise SystemExit(0)

record = json.loads(match.group(0))
accepted = record.get("accepted")
failure = record.get("failureClass")
refs = record.get("parsedSupportReferences") or []

project_refs = [
    ref for ref in refs
    if ref.get("type") == "project_context_excerpt"
]

bad = [
    ref for ref in project_refs
    if re.search(r":\d+$", str(ref.get("relativePath", "")))
]

print(f"ACCEPTED={str(accepted).upper()}")
print(f"FAILURE_CLASS={failure}")
print(f"PROJECT_CONTEXT_REFERENCE_COUNT={len(project_refs)}")
print(f"RELATIVE_PATH_WITH_COLON_LINE_SUFFIX_COUNT={len(bad)}")

if accepted is True:
    print("POST_TIMEOUT_RESULT=SEMANTIC_ACCEPTANCE")
    print("NINETY_SECOND_TIMEOUT_VALIDATED=YES")
    print("SUPPORT_REFERENCE_FIX_VALIDATED=YES")
elif failure:
    print("POST_TIMEOUT_RESULT=RETURNED_AND_FAIL_CLOSED_REJECTED")
    print("NINETY_SECOND_TIMEOUT_VALIDATED=YES")
    print("SUPPORT_REFERENCE_FIX_VALIDATED=NO")
else:
    print("POST_TIMEOUT_RESULT=RETURNED_WITHOUT_FINAL_CLASSIFICATION")
    print("NINETY_SECOND_TIMEOUT_VALIDATED=YES")
    print("SUPPORT_REFERENCE_FIX_VALIDATED=INDETERMINATE")
PY

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  "RUN_STATUS=$RUN_STATUS" \
  'AUTHORIZED_INVOCATIONS_USED=1_OF_1' \
  'SECOND_INVOCATION_STARTED=NO' \
  'DASHBOARD_SMOKE_TEST_STARTED=NO' \
  'TIMEOUT_CHANGED_AGAIN=NO' \
  'PROMPT_CHANGED=NO' \
  'VALIDATOR_CHANGED=NO' \
  'MODEL_CHANGED=NO' \
  'RETRY_CHANGED=NO' \
  'GENERATION_POLICY_CHANGED=NO' \
  'ISSUE_RESOLUTION_NOT_YET_DECLARED=YES'

git status --short
