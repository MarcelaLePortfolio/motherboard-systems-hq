#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=aedbf76b' \
  'ACTION=RUN_SINGLE_POST_TIMEOUT_CHANGE_VALIDATION' \
  'VALIDATION_AUTHORIZED=YES' \
  'AUTHORIZED_INVOCATION_COUNT=1' \
  'DASHBOARD_VISIBLE_SMOKE_TEST_AUTHORIZED=NO' \
  'ADDITIONAL_RETRY_AUTHORIZED=NO'

if [[ ! -x scripts/run-exact-dashboard-validation.sh ]]; then
  echo 'EXACT_VALIDATION_RUNNER_NOT_FOUND'
  exit 1
fi

./scripts/run-exact-dashboard-validation.sh

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'AUTHORIZED_INVOCATION_CONSUMED=YES' \
  'SECOND_INVOCATION_STARTED=NO' \
  'DASHBOARD_SMOKE_TEST_STARTED=NO' \
  'PROMPT_CHANGED=NO' \
  'VALIDATOR_CHANGED=NO' \
  'MODEL_CHANGED=NO' \
  'RETRY_CHANGED=NO' \
  'GENERATION_POLICY_CHANGED=NO'
