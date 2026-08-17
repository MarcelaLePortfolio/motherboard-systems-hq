#!/usr/bin/env bash
set -u

echo "=== PHASE 3 / CORRIDOR 2 — OBSERVABILITY CHECK DIAGNOSIS ==="

echo "BRANCH=$(git branch --show-current)"
echo "HEAD=$(git rev-parse --short HEAD)"
echo "WORKTREE:"
git status --short

check() {
  local label="$1"
  local pattern="$2"
  local file="$3"

  if grep -Fq "$pattern" "$file"; then
    echo "$label=PASS"
  else
    echo "$label=FAIL"
  fi
}

check \
  "VALIDATED_SELECTED_CONTEXT_OBSERVER" \
  "observeValidatedSelectedContextSegments" \
  "scripts/utils/ollamaChat.ts"

check \
  "PARSED_SUPPORT_REFERENCE_OBSERVER" \
  "observeParsedSupportSourceReferences" \
  "scripts/utils/ollamaChat.ts"

check \
  "STRUCTURED_PARSE_CALL" \
  "parseStructuredResponse(rawResponse)" \
  "scripts/utils/ollamaChat.ts"

check \
  "SELECTED_CONTEXT_FAIL_CLOSED_ERROR" \
  "Ollama returned a selected context segment that was not supplied in this invocation." \
  "scripts/utils/ollamaChat.ts"

echo "DIAGNOSIS_ONLY=YES"
echo "PRODUCTION_CHANGE=NONE"
echo "DR_NOW=NO"
echo "NEXT_ACTION=USE_FAILED_CHECK_TO_CORRECT_CLASSIFICATION_SCRIPT_WITHOUT_STARTING_THIRD_VALIDATION_ATTEMPT"
