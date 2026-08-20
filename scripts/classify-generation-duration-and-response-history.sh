#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=d5401a8c' \
  'ACTION=CLASSIFY_GENERATION_DURATION_AND_RESPONSE_HISTORY_FROM_EXISTING_EVIDENCE' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'PRODUCTION_CHANGE=NO'

printf '\n=== EXISTING DASHBOARD VALIDATION RESULTS ===\n'
for file in \
  docs/checkpoints/MATILDA_UI_503_SUPPORT_REFERENCE_SINGLE_DIAGNOSTIC_RESULT.txt \
  docs/checkpoints/MATILDA_UI_503_POST_FIX_SINGLE_VALIDATION_RESULT.txt \
  docs/checkpoints/MATILDA_UI_503_SECOND_POST_FIX_VALIDATION_RESULT.txt
do
  if [[ -f "$file" ]]; then
    echo "--- $file"
    grep -nE \
      '"accepted"|"failureClass"|"errorMessage"|"parsedSupportReferenceCount"|"fingerprint"|"reply"|"durableInterpretation"' \
      "$file" || true
  fi
done

printf '\n=== HISTORICAL TIMEOUT / GENERATION EVIDENCE ===\n'
grep -RniE \
  'OLLAMA_TIMEOUT|timed out|FIXTURE_SEMANTIC_PASS|UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE|SEMANTIC_ACCEPTANCE_FAILURE' \
  docs/checkpoints scripts \
  --exclude='classify-generation-duration-and-response-history.sh' \
  2>/dev/null | tail -250 || true

printf '\n=== RESPONSE SIZE EVIDENCE AVAILABLE ===\n'
python3 - << 'PY'
from pathlib import Path
import re

files = [
    Path("docs/checkpoints/MATILDA_UI_503_SUPPORT_REFERENCE_SINGLE_DIAGNOSTIC_RESULT.txt"),
    Path("docs/checkpoints/MATILDA_UI_503_POST_FIX_SINGLE_VALIDATION_RESULT.txt"),
    Path("docs/checkpoints/MATILDA_UI_503_SECOND_POST_FIX_VALIDATION_RESULT.txt"),
]

for path in files:
    if not path.exists():
        continue

    text = path.read_text()
    replies = re.findall(r'"reply":\s*(null|"(?:(?:\\.)|[^"\\])*")', text)
    durable = re.findall(
        r'"durableInterpretation":\s*(null|"(?:(?:\\.)|[^"\\])*")',
        text,
    )

    print(f"FILE={path}")
    print(f"REPLY_FIELDS_FOUND={len(replies)}")
    print(
        "NON_NULL_REPLY_FIELDS="
        f"{sum(1 for value in replies if value != 'null')}"
    )
    print(
        "NON_NULL_DURABLE_INTERPRETATION_FIELDS="
        f"{sum(1 for value in durable if value != 'null')}"
    )
PY

printf '\n=== CLASSIFICATION ===\n'
printf '%s\n' \
  'PRE_FIX_DIAGNOSTIC_RESPONSE_RETURNED_BEFORE_TIMEOUT=YES' \
  'PRE_FIX_DIAGNOSTIC_REACHED_SUPPORT_REFERENCE_VALIDATION=YES' \
  'POST_FIX_ATTEMPT_1_REACHED_PARSED_OUTPUT=NO' \
  'POST_FIX_ATTEMPT_2_REACHED_PARSED_OUTPUT=NO' \
  'POST_FIX_TIMEOUT_COUNT=2' \
  'PROMPT_FIX_STATIC_SIZE_DELTA_PERCENT_APPROX=1.68' \
  'PROMPT_FIX_CREATED_LARGE_STATIC_SOURCE_EXPANSION=NO' \
  'EXACT_GENERATION_DURATION_HISTORY_AVAILABLE=NO' \
  'EXACT_RESPONSE_TOKEN_HISTORY_AVAILABLE=NO' \
  'RESPONSE_LENGTH_AS_TIMEOUT_CAUSE_ESTABLISHED=NO' \
  'PROMPT_SIZE_AS_TIMEOUT_CAUSE_ESTABLISHED=NO' \
  'RUNTIME_GENERATION_VARIANCE_REMAINS_PLAUSIBLE=YES' \
  'SUPPORT_REFERENCE_FIX_VALIDATED=NO' \
  'SUPPORT_REFERENCE_FIX_DISPROVEN=NO' \
  'THIRD_IDENTICAL_VALIDATION_JUSTIFIED=NO'

printf '\n=== NEXT BOUNDED CLASS ===\n'
printf '%s\n' \
  'NEXT_ACTION=INVESTIGATE_NON_GENERATIVE_OLLAMA_AND_REQUEST_TELEMETRY_AVAILABLE_FOR_DURATION_CLASSIFICATION' \
  'PURPOSE=DETERMINE_WHETHER_EXISTING_OLLAMA_OR_RUNNER_LOGGING_CAN_DISTINGUISH_PROMPT_EVALUATION_FROM_RESPONSE_GENERATION_DELAY_WITHOUT_STARTING_A_THIRD_MODEL_INVOCATION' \
  'THIRD_OLLAMA_INVOCATION_AUTHORIZED=NO' \
  'TIMEOUT_CHANGE_AUTHORIZED=NO' \
  'PROMPT_CHANGE_AUTHORIZED=NO' \
  'MODEL_CHANGE_AUTHORIZED=NO'

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'OLLAMA_GENERATION_STARTED=NO' \
  'TIMEOUT_CHANGED=NO' \
  'MODEL_CHANGED=NO' \
  'VALIDATOR_CHANGED=NO' \
  'PROMPT_CHANGED=NO' \
  'GENERATION_POLICY_CHANGED=NO'

printf '\n=== WORKTREE ===\n'
git status --short
