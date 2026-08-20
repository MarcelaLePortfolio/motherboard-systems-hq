#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

FILE="scripts/utils/ollamaChat.ts"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=e60bd5dd' \
  'ISSUE_RESOLVED=NO' \
  'ACTION=INVESTIGATE_SUPPORT_REFERENCE_OUTPUT_CONTRACT_INTERACTION' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'PRODUCTION_CHANGE=NO'

printf '\n=== SUPPORT REFERENCE PROMPT PRESENTATION ===\n'
grep -n -A18 -B10 \
  'Display identity\|relativePath =\|lineNumber =' \
  "$FILE" || true

printf '\n=== OUTPUT SCHEMA ===\n'
grep -n -A80 -B15 \
  'supportReferences\|relativePath.*string\|lineNumber.*integer' \
  "$FILE" | head -220 || true

printf '\n=== MODEL INSTRUCTIONS FOR STRUCTURED SUPPORT REFERENCES ===\n'
grep -n -A30 -B20 \
  'copy relativePath\|raw repo path\|Display identity\|support reference' \
  "$FILE" | head -260 || true

printf '\n=== VALIDATOR MEMBERSHIP KEYS ===\n'
grep -n -A35 -B15 \
  'suppliedProjectContext\|project-context support reference\|reference.relativePath\|reference.lineNumber' \
  "$FILE" | head -260 || true

printf '\n=== DISPLAY FORM OCCURRENCES ===\n'
grep -nE \
  '\$\{[^}]*relativePath[^}]*\}:\$\{[^}]*lineNumber[^}]*\}|relativePath.*lineNumber|Source:' \
  "$FILE" || true

printf '\n=== CLASSIFICATION TARGET ===\n'
printf '%s\n' \
  'QUESTION_1=DOES_ANY_MODEL_VISIBLE_PROMPT_SURFACE_STILL_PRESENT_PROJECT_CONTEXT_IDENTITY_PRIMARILY_AS_PATH_COLON_LINE' \
  'QUESTION_2=DOES_OUTPUT_SCHEMA_DESCRIPTION_IMPLY_COMBINED_IDENTITY_FOR_RELATIVE_PATH' \
  'QUESTION_3=DO_MULTIPLE_CONFLICTING_PRESENTATIONS_EXIST_FOR_THE_SAME_SUPPORT_REFERENCE' \
  'QUESTION_4=IS_A_BOUNDED_PROMPT_OR_SCHEMA_DESCRIPTION_CORRECTION_SUPPORTED_WITHOUT_VALIDATOR_CHANGE'

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'OLLAMA_REQUEST_STARTED=NO' \
  'DASHBOARD_SMOKE_TEST_STARTED=NO' \
  'PROMPT_CHANGED=NO' \
  'OUTPUT_SCHEMA_CHANGED=NO' \
  'VALIDATOR_CHANGED=NO' \
  'MODEL_CHANGED=NO' \
  'TIMEOUT_CHANGED=NO' \
  'RETRY_CHANGED=NO' \
  'GENERATION_POLICY_CHANGED=NO'

git status --short
