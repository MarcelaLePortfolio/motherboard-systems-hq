#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT SINGLE OLLAMA STRUCTURED PACKAGE SEMANTICS BOUNDARY ==="
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

echo
echo "=== OLLAMA RESULT AND STRUCTURED RESPONSE TYPES ==="
rg -n -C 8 \
  'durableInterpretation|investigationLifecycle|supportSourceReferences|evidenceSufficient|interface .*Result|type .*Result|structured response|StructuredResponse' \
  server db \
  --glob '*.ts' || true

echo
echo "=== PROMPT CONTRACT ==="
rg -n -C 10 \
  'durableInterpretation|reply|investigationLifecycle|supportSourceReferences|evidenceSufficient|JSON|schema|respond|response' \
  server \
  --glob '*.ts' || true

echo
echo "=== RESPONSE PARSER AND VALIDATION ==="
rg -n -C 10 \
  'parse|validate|validator|durableInterpretation|investigationLifecycle|supportSourceReferences|evidenceSufficient' \
  server \
  --glob '*.ts' || true

echo
echo "=== EXISTING OPTIONAL MODEL-AUTHORED ARTIFACT PATTERNS ==="
rg -n -C 10 \
  'investigationLifecycle|supportSourceReferences|priorInvestigationLifecycle|optional|nullable|null' \
  server \
  --glob '*.ts' || true

echo
echo "=== CURRENT LIVING DRAFT SYNTHESIS INPUT BOUNDARY ==="
rg -n -C 12 \
  'synthesize|draft synthesis|current_interpretation|proposed_work|proposed_artifacts|in_scope|out_of_scope|constraints|expected_outcome|unresolved_questions' \
  db/matilda-draft-synthesis-runtime.ts \
  server/matilda-chat-workflow.ts || true

echo
echo "=== SAFETY BOUNDARY ==="
echo "SECOND_OLLAMA_INVOCATION_AUTHORIZED=NO"
echo "HEURISTIC_EXTRACTION_AUTHORIZED=NO"
echo "SYNTHESIS_CHANGE_AUTHORIZED=NO"
echo "OLLAMA_CONTRACT_CHANGE_AUTHORIZED=NO"
echo "AUTHORITY_MODEL_CHANGE_AUTHORIZED=NO"
echo "NEXT_ACTION=CLASSIFY_WHETHER_EXISTING_SINGLE_INVOCATION_CONTRACT_CAN_SAFELY_CARRY_REQUEST_SPECIFIC_LIVING_DRAFT_SEMANTICS"

