#!/usr/bin/env bash
set -euo pipefail

echo "=== INVESTIGATE PROMPT AND RESPONSE CONTRACT PRESENTATION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor 4d4b26dd HEAD

starting_boundary="scripts/open-generation-layer-intervention-investigation-starting-boundary.sh"
ollama="scripts/utils/ollamaChat.ts"

for artifact in "$starting_boundary" "$ollama"; do
  test -f "$artifact"
  echo "PRESENT=$artifact"
done

echo
echo "=== VERIFY PHASE 2 STARTING BOUNDARY ==="
grep -q 'PHASE_2=' "$starting_boundary"
grep -q 'GENERATION_LAYER_INTERVENTION_INVESTIGATION' "$starting_boundary"
grep -q 'ACTIVE_CORRIDOR=' "$starting_boundary"
grep -q 'PROMPT_AND_RESPONSE_CONTRACT_PRESENTATION' "$starting_boundary"
echo "PHASE_2_STARTING_BOUNDARY=CONFIRMED"

echo
echo "=== VERIFY CURRENT PROMPT SUPPORT-PROVENANCE INSTRUCTIONS ==="
grep -q 'Set supportSourceReferences to only the supplied conversation turns or parent project-context excerpts' "$ollama"
grep -q 'For project-context support, use type project_context_excerpt with the exact relativePath and lineNumber supplied' "$ollama"
grep -q 'For project_context_excerpt support, use only a Source identity explicitly shown under Bounded project context evidence' "$ollama"
grep -q 'Never use a Segment source line range, sourceStartLine, sourceEndLine, or child segment line number as a project_context_excerpt support identity' "$ollama"
grep -q 'Do not invent, reconstruct, approximate, or reference a source identifier that was not supplied in this invocation' "$ollama"
grep -q 'Return an empty supportSourceReferences array when no supplied source explicitly supports' "$ollama"
echo "PROMPT_SUPPORT_PROVENANCE_INSTRUCTIONS=CONFIRMED"

echo
echo "=== VERIFY SUPPLIED SOURCE PRESENTATION ==="
grep -q 'Bounded project context evidence:' "$ollama"
grep -q 'Source: ${item.relativePath}:${item.lineNumber}' "$ollama"
grep -q 'Project-context segment candidates:' "$ollama"
grep -q 'relativePath = ${item.relativePath}' "$ollama"
grep -q 'sourceStartLine = ${item.sourceStartLine}' "$ollama"
grep -q 'sourceEndLine = ${item.sourceEndLine}' "$ollama"
echo "SOURCE_PRESENTATION=CONFIRMED"

echo
echo "=== VERIFY FAIL-CLOSED MATCHING ==="
grep -q 'suppliedProjectContextSources' "$ollama"
grep -q 'Ollama returned a project-context support reference that was not supplied in this invocation' "$ollama"
grep -q 'Ollama returned project-context support without selecting a supplied child segment for that parent' "$ollama"
echo "FAIL_CLOSED_MATCHING=CONFIRMED"

cat <<'MAP'
PROGRAM=
MATILDA_CONVERSATION_ENGINE

MILESTONE=
CONVERSATION_ENGINE_RELIABLE_PRODUCTION_COLLABORATION

PHASE_2=
GENERATION_LAYER_INTERVENTION_INVESTIGATION

CORRIDOR_1=
PROMPT_AND_RESPONSE_CONTRACT_PRESENTATION

CURRENT_PROMPT_CONTRACT=
EXPLICIT_SUPPORT_PROVENANCE_RULES_PRESENT

CURRENT_PROJECT_CONTEXT_PARENT_IDENTITY_PRESENTATION=
RELATIVE_PATH_COLON_LINE_NUMBER

CURRENT_CHILD_SEGMENT_IDENTITY_PRESENTATION=
RELATIVE_PATH_PLUS_SOURCE_START_LINE_PLUS_SOURCE_END_LINE

CURRENT_MODEL_INSTRUCTION=
PROJECT_CONTEXT_SUPPORT_MUST_USE_EXACT_PARENT_SOURCE_IDENTITY_SUPPLIED_UNDER_BOUNDED_PROJECT_CONTEXT_EVIDENCE

CURRENT_MODEL_PROHIBITIONS=
DO_NOT_USE_CHILD_SEGMENT_LINE_RANGE_AS_PARENT_SUPPORT_IDENTITY
DO_NOT_INVENT_SOURCE_IDENTITY
DO_NOT_RECONSTRUCT_SOURCE_IDENTITY
DO_NOT_APPROXIMATE_SOURCE_IDENTITY

CURRENT_EMPTY_SUPPORT_RULE=
RETURN_EMPTY_SUPPORT_SOURCE_REFERENCES_WHEN_NO_SUPPLIED_SOURCE_SUPPORTS_THE_CONCLUSION

CURRENT_VALIDATION_RULE=
PROJECT_CONTEXT_SUPPORT_REFERENCE_MUST_EXACTLY_MATCH_A_SUPPLIED_PARENT_SOURCE

CURRENT_PARENT_CHILD_CONSISTENCY_RULE=
PROJECT_CONTEXT_SUPPORT_REQUIRES_AT_LEAST_ONE_SELECTED_SUPPLIED_CHILD_WHEN_CHILDREN_EXIST

OBSERVED_FAILURE=
MODEL_CAN_STILL_AUTHOR_AN_UNSUPPLIED_PROJECT_CONTEXT_SUPPORT_REFERENCE_DESPITE_EXPLICIT_PROMPT_PROHIBITIONS

PROMPT_RULE_ABSENCE_AS_CAUSE=
NOT_ESTABLISHED

PROMPT_RULE_AMBIGUITY_AS_CAUSE=
NOT_ESTABLISHED

PROMPT_PRESENTATION_COMPLEXITY_AS_CONTRIBUTING_FACTOR=
PLAUSIBLE_BUT_NOT_ESTABLISHED

PARENT_CHILD_IDENTITY_CONFUSION_AS_CONTRIBUTING_FACTOR=
PLAUSIBLE_BUT_NOT_ESTABLISHED

PROMPT_CHANGE_REQUIREMENT=
NOT_YET_ESTABLISHED

PROMPT_CHANGE_IMPLEMENTATION=
NOT_AUTHORIZED

CORRIDOR_DETERMINATION=
CURRENT_PROMPT_ALREADY_STATES_THE_CRITICAL_PROVENANCE_RULES_EXPLICITLY_SO_SIMPLE_MISSING_INSTRUCTION_IS_NOT_AN_EVIDENCE_SUPPORTED_ROOT_CAUSE

NEXT_INVESTIGATION_NEED=
DETERMINE_WHETHER_PRESENTATION_STRUCTURE_OR_IDENTITY_COMPLEXITY_MATERIALLY_DRIVES_FAILURE_BEFORE_ANY_PROMPT_CHANGE_IS_PROPOSED

IMPLEMENTATION_AUTHORIZED=
NO

IMPLEMENTATION_STARTED=
NO

PRODUCTION_CHANGE=
NONE

CORRIDOR_1_STATUS=
ACTIVE

NEXT_ACTION=
CLASSIFY_PROMPT_PRESENTATION_COMPLEXITY_AND_PARENT_CHILD_IDENTITY_RISK
MAP
