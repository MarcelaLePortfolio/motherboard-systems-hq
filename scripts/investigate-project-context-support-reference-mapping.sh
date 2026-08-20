#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

RESULT="docs/checkpoints/MATILDA_UI_503_REPLACEMENT_CONTROLLED_COMPARISON_RESULT.txt"
OLLAMA="scripts/utils/ollamaChat.ts"
RETRIEVAL="server/matilda-project-context-retrieval.ts"

printf '%s\n' \
  'CHECKPOINT=MATILDA_UI_SMOKE_TEST_503' \
  'CURRENT_CHECKPOINT=d2a5b8e4' \
  'ISSUE_RESOLVED=NO' \
  'MODE=COLLABORATION_DIAGNOSTIC' \
  'TARGET=CLASSIFY_PROJECT_CONTEXT_SUPPORT_REFERENCE_MAPPING_GAP' \
  'PRODUCTION_CHANGE=NO' \
  'NEW_OLLAMA_INVOCATION=NO'

printf '\n=== SUPPORT REFERENCE PROMPT CONTRACT ===\n'
grep -n -A35 -B20 -E \
  'For project-context support|project_context_excerpt|supportSourceReferences|Bounded project context evidence|Source identity|Segment source' \
  "$OLLAMA" || true

printf '\n=== SUPPORT REFERENCE VALIDATION ===\n'
grep -n -A50 -B25 -E \
  'project-context support reference that was not supplied|supportSourceReferences|project_context_excerpt' \
  "$OLLAMA" || true

printf '\n=== PROJECT CONTEXT IDENTITY CONSTRUCTION ===\n'
grep -n -A45 -B20 -E \
  'relativePath|lineNumber|sourceStartLine|sourceEndLine|segmentId|sourceIdentity|Source identity' \
  "$RETRIEVAL" "$OLLAMA" || true

printf '\n=== CONTROLLED FAILURE SHAPE ===\n'
grep -n -A14 -B2 \
  '"failureClass": "UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE"' \
  "$RESULT" | head -180 || true

printf '\n=== OBSERVER SURFACE ===\n'
grep -n -A35 -B20 -E \
  'observeParsedSupportSourceReferences|parsedSupport|validatedSelected|supportSourceReferences' \
  scripts/run-dashboard-generation-control-comparison.ts "$OLLAMA" || true

printf '\n=== CLASSIFICATION QUESTIONS ===\n'
printf '%s\n' \
  'QUESTION_1=WHAT_EXACT_PROJECT_CONTEXT_IDENTITIES_ARE_RENDERED_INTO_THE_PROMPT' \
  'QUESTION_2=WHAT_EXACT_IDENTITY_SHAPE_THE_MODEL_RETURNS' \
  'QUESTION_3=WHAT_EXACT_IDENTITY_SHAPE_THE_VALIDATOR_ACCEPTS' \
  'QUESTION_4=WHETHER_PROMPT_PRESENTATION_AND_VALIDATOR_MEMBERSHIP_USE_THE_SAME_PARENT_SOURCE_IDENTITY' \
  'QUESTION_5=WHETHER_CHILD_SEGMENT_LINE_NUMBERS_OR_RANGES_ARE_BEING_MISTAKEN_FOR_PARENT_SOURCE_IDENTITIES'

printf '\n=== SAFETY BOUNDARY ===\n'
printf '%s\n' \
  'PROMPT_CHANGE_AUTHORIZED=NO' \
  'VALIDATOR_CHANGE_AUTHORIZED=NO' \
  'VALIDATOR_WEAKENING_AUTHORIZED=NO' \
  'GENERATION_POLICY_CHANGE_AUTHORIZED=NO' \
  'MODEL_CHANGE_AUTHORIZED=NO' \
  'NEXT_ACTION=CLASSIFY_EXACT_IDENTITY_MAPPING_GAP_FROM_REPOSITORY_EVIDENCE_BEFORE_PROPOSING_ANY_FIX'

printf '\n=== WORKTREE ===\n'
git status --short
