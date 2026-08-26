#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT MINIMUM FAIL-CLOSED PACKAGE SEMANTICS CONTRACT ==="
echo "BASELINE_COMMIT=f8f1e334"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== OLLAMA CHAT TYPES AND RESULT CONTRACT ==="
rg -n -C 12 \
  'export type|export interface|durableInterpretation|reply|investigationLifecycle|supportSourceReferences|evidenceSufficient' \
  scripts/utils/ollamaChat.ts \
  server \
  --glob '*.ts' || true

echo
echo "=== STRUCTURED RESPONSE PROMPT / JSON CONTRACT ==="
rg -n -C 12 \
  'durableInterpretation|investigationLifecycle|supportSourceReferences|evidenceSufficient|JSON|schema|structured response|exactly|nullable' \
  scripts/utils/ollamaChat.ts \
  server \
  --glob '*.ts' || true

echo
echo "=== INVESTIGATION LIFECYCLE VALIDATOR PRECEDENT ==="
rg -n -C 14 \
  'validateMatildaInvestigationLifecycleArtifact|MatildaInvestigationLifecycleArtifact|investigationLifecycle' \
  scripts server db \
  --glob '*.ts' || true

echo
echo "=== PARSER FAILURE / FAIL-CLOSED PATHS ==="
rg -n -C 12 \
  'throw new Error|invalid|malformed|fail.closed|parse|JSON.parse|validation' \
  scripts/utils/ollamaChat.ts \
  server \
  --glob '*.ts' || true

echo
echo "=== REQUIRED DESIGN QUESTIONS ==="
echo "FIELD_SET=expectedOutcome,proposedWork,proposedArtifacts,inScope,outOfScope,constraints,unresolvedQuestions"
echo "QUESTION_1=SHOULD_PACKAGE_SEMANTICS_BE_NULLABLE_AS_ONE_ARTIFACT_OR_FIELD_BY_FIELD"
echo "QUESTION_2=WHICH_FIELDS_MUST_BE_NONEMPTY_WHEN_ARTIFACT_IS_PRESENT"
echo "QUESTION_3=WHAT_FAIL_CLOSED_BEHAVIOR_APPLIES_TO_MALFORMED_MODEL_OUTPUT"
echo "QUESTION_4=HOW_IS_VALIDATED_ARTIFACT_PERSISTED_WITHOUT_CHANGING_ONE_WORKFLOW_ONE_IEL_ENTRY"
echo "QUESTION_5=HOW_DOES_LIVING_DRAFT_SYNTHESIS_USE_VALIDATED_VALUES_WITHOUT_GENERIC_FALLBACKS_MASKING_ABSENCE"

echo
echo "=== BOUNDARY ==="
echo "SECOND_OLLAMA_INVOCATION_AUTHORIZED=NO"
echo "HEURISTIC_EXTRACTION_AUTHORIZED=NO"
echo "OLLAMA_CONTRACT_CHANGE_AUTHORIZED=NO"
echo "IEL_SCHEMA_CHANGE_AUTHORIZED=NO"
echo "SYNTHESIS_CHANGE_AUTHORIZED=NO"
echo "NEXT_ACTION=DESIGN_MINIMUM_TYPED_PACKAGE_SEMANTICS_ARTIFACT_FROM_VERIFIED_EXISTING_VALIDATOR_AND_PARSER_PATTERNS"
