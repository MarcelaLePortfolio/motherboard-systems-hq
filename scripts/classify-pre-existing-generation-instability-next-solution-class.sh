#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=c87dabc6' \
  'ISSUE_RESOLVED=NO' \
  'MODE=COLLABORATION_SOLUTION_CLASSIFICATION' \
  'PRE_FIX_RUNTIME_REVALIDATION=FAIL' \
  'OBSERVED_FAILURE=UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE' \
  'REFERENCE_SPECIFIC_PROMPT_FIX_REVERTED=YES' \
  'REFERENCE_SPECIFIC_PROMPT_HYPOTHESIS=CLOSED' \
  'TARGET=SELECT_DIFFERENT_SOLUTION_CLASS_FROM_REPOSITORY_EVIDENCE'

printf '\n=== RELEVANT GENERATION STABILITY HISTORY ===\n'
git log --oneline --decorate --all --grep='Generation Stability' -20 || true
git log --oneline --decorate --all --grep='Production Sampling Policy' -10 || true
git log --oneline --decorate --all --grep='Generation Controls' -10 || true
git log --oneline --decorate --all --grep='Validation vs. Production Controls' -10 || true
git log --oneline --decorate --all --grep='Request vs. Shared Policy' -10 || true
git log --oneline --decorate --all --grep='Semantic Preservation' -10 || true

printf '\n=== CURRENT GENERATION CONTROL SURFACE ===\n'
grep -n -E \
  'validationGenerationSeed|options:|seed|temperature|top_p|top_k|num_predict|timeout|AbortController|setTimeout' \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts \
  routes/api-chat.ts || true

printf '\n=== PROJECT CONTEXT SUPPORT VALIDATION SURFACE ===\n'
grep -n -A35 -B25 -E \
  'project-context support reference|project_context_excerpt|supportSourceReferences|suppliedProjectContext|allowedProjectContext|relativePath.*lineNumber' \
  scripts/utils/ollamaChat.ts || true

printf '\n=== CLASSIFICATION ===\n'
printf '%s\n' \
  'PRE_EXISTING_GENERATION_INSTABILITY_CONFIRMED_ON_RESTORED_BASELINE=YES' \
  'EMPTY_HISTORY_PROMPT_FIX_ROOT_CAUSE=NO' \
  'DASHBOARD_PROXY_ROOT_CAUSE=NO' \
  'VALIDATOR_MALFUNCTION_ESTABLISHED=NO' \
  'FAIL_CLOSED_VALIDATION_MUST_REMAIN=YES' \
  'NEXT_SOLUTION_CLASS=GENERATION_POLICY_AND_CONTROL_BOUNDARY_REASSESSMENT' \
  'IMPLEMENTATION_AUTHORIZED=NO' \
  'REASON=MODEL_OUTPUT_VARIABILITY_REMAINS_CAPABLE_OF_PRODUCING_INVALID_SUPPORT_PROVENANCE_ON_UNCHANGED_UNSEEDED_RUNTIME'

printf '\n=== NEXT DECISION BOUNDARY ===\n'
printf '%s\n' \
  'DO_NOT_ADD_ANOTHER_REFERENCE_SPECIFIC_PROMPT_PATCH=YES' \
  'DO_NOT_WEAKEN_SUPPORT_REFERENCE_VALIDATION=YES' \
  'DO_NOT_ADD_RETRY_OR_TIMEOUT_CHANGE_YET=YES' \
  'DO_NOT_CHANGE_MODEL_YET=YES' \
  'DO_NOT_ENABLE_PRODUCTION_SEED_YET=YES' \
  'NEXT_ACTION=REASSESS_PREVIOUS_PHASE_2_NO_POLICY_DETERMINATION_AGAINST_NEW_LIVE_DASHBOARD_FAILURE_EVIDENCE'

printf '\n=== WORKTREE ===\n'
git status --short
