#!/usr/bin/env bash
set -euo pipefail

echo "=== PHASE 3 / CORRIDOR 2 — CONTEXT VALIDATION FIXTURE INSPECTION ==="

test "$(git branch --show-current)" = "feature/support-source-references-runtime"

echo "OBSERVED_ATTEMPT_1_FAILURE=SELECTED_CONTEXT_SEGMENT_NOT_SUPPLIED"
echo "TARGET_EXPLANATION_STATUS_OBSERVED=NO"
echo "FAIL_CLOSED_BOUNDARY=PRESERVE"
echo "PRODUCTION_CHANGE=NONE"
echo "DR_NOW=NO"

printf '\n--- EXACT FAIL-CLOSED MEMBERSHIP CHECK ---\n'
grep -n -B35 -A55 \
'Ollama returned a selected context segment that was not supplied in this invocation' \
scripts/utils/ollamaChat.ts

printf '\n--- PROJECT CONTEXT SEGMENT CANDIDATE TYPE ---\n'
grep -n -B15 -A45 \
'interface OllamaChatProjectContextSegmentCandidate' \
scripts/utils/ollamaChat.ts

printf '\n--- ALL VALIDATION HARNESSES SUPPLYING SEGMENT CANDIDATES ---\n'
grep -RIn -B18 -A55 \
'projectContextSegmentCandidates:' \
scripts \
--include='*.ts' \
--exclude='validate-phase-3-corridor-2-reasoning-status-behavior.ts' \
2>/dev/null | head -n 500

printf '\n--- TEST FIXTURES EXERCISING VALID SELECTED CONTEXT ---\n'
grep -RIn -B20 -A65 -E \
'selectedContextSegments.*relativePath|observeValidatedSelectedContextSegments|sourceStartLine.*sourceEndLine' \
scripts/utils \
--include='*.test.ts' \
2>/dev/null | head -n 500

cat <<'MAP'

CURRENT_DETERMINATION=
ATTEMPT_1_CONFIRMED_THE_HARNESS_OMITTED_A_CONTEXT_CANDIDATE_SURFACE_WHILE_THE_STRUCTURED_CONTRACT_STILL_REQUIRED_MODEL_AUTHORED_SELECTED_CONTEXT

NEXT_DECISION=
IDENTIFY_AN_EXISTING_PASSING_CANDIDATE_FIXTURE_AND_REUSE_ITS_EXACT_SHAPE_FOR_ATTEMPT_2

ATTEMPT_2_NOT_STARTED=
YES

DO_NOT_CHANGE=
PRODUCTION_VALIDATOR
PRODUCTION_PROMPT
STRUCTURED_SCHEMA
RETRY_POLICY
MODEL_INVOCATION_COUNT

NEXT_ACTION=
USE_REPOSITORY_EVIDENCE_FROM_THIS_INSPECTION_TO_CONSTRUCT_SECOND_BOUNDED_BEHAVIOR_VALIDATION_ATTEMPT
MAP
