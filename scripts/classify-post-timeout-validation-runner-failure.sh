#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=eb4f2803' \
  'ACTION=CLASSIFY_POST_TIMEOUT_VALIDATION_RUNNER_FAILURE' \
  'ISSUE_RESOLVED=NO'

printf '\n=== RUNNER FAILURE CLASSIFICATION ===\n'
printf '%s\n' \
  'AUTHORIZED_VALIDATION_INVOCATION_ACTUALLY_STARTED=NO' \
  'OLLAMA_REQUEST_STARTED=NO' \
  'FAILURE_POINT=PRE_INVOCATION_RUNNER_LOOKUP' \
  'FAILURE=EXACT_VALIDATION_RUNNER_NOT_FOUND' \
  'AUTHORIZED_MODEL_INVOCATION_CONSUMED=NO' \
  'TIMEOUT_FIX_VALIDATED=NO' \
  'TIMEOUT_FIX_DISPROVEN=NO' \
  'SUPPORT_REFERENCE_FIX_VALIDATED=NO' \
  'SUPPORT_REFERENCE_FIX_DISPROVEN=NO'

printf '\n=== NEXT BOUNDED ACTION ===\n'
printf '%s\n' \
  'NEXT_ACTION=DISCOVER_EXISTING_EXACT_DASHBOARD_VALIDATION_RUNNER_OR_RECONSTRUCT_FROM_VERIFIED_PRIOR_VALIDATION_ARTIFACTS' \
  'NEW_OLLAMA_INVOCATION=NO' \
  'PRODUCTION_CHANGE=NO' \
  'VALIDATION_AUTHORIZATION_REMAINS_AVAILABLE=YES'

printf '\n=== EXISTING VALIDATION RUNNER CANDIDATES ===\n'
find scripts -maxdepth 2 -type f \
  \( -iname '*dashboard*validation*.sh' \
     -o -iname '*post*fix*.sh' \
     -o -iname '*support*reference*.sh' \
     -o -iname '*ollama*validation*.sh' \
     -o -iname '*controlled*comparison*.sh' \) \
  -print | sort

printf '\n=== EXACT REQUEST REFERENCES ===\n'
grep -RniF \
  'Create a simple internal status dashboard for tracking three workstreams: Product, Operations, and Marketing.' \
  scripts docs/checkpoints 2>/dev/null | head -100 || true

printf '\n=== OLLAMACHAT VALIDATION CALL SITES ===\n'
grep -RniE \
  'ollamaChat\(|run.*dashboard|dashboard.*validation|post.*fix.*validation' \
  scripts 2>/dev/null | head -200 || true

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'SECOND_INVOCATION_STARTED=NO' \
  'DASHBOARD_SMOKE_TEST_STARTED=NO' \
  'TIMEOUT_CHANGED_AGAIN=NO' \
  'PROMPT_CHANGED=NO' \
  'VALIDATOR_CHANGED=NO' \
  'MODEL_CHANGED=NO' \
  'RETRY_CHANGED=NO'

git status --short
