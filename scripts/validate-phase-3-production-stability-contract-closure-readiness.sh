#!/usr/bin/env bash
set -euo pipefail

echo "=== VALIDATE PHASE 3 CORRIDOR 1 — PRODUCTION STABILITY CONTRACT CLOSURE READINESS ==="

contract="scripts/define-phase-3-production-stability-validation-contract.sh"

test "$(git branch --show-current)" = "feature/support-source-references-runtime"
test -z "$(git status --porcelain)"
git merge-base --is-ancestor d8256e8d HEAD
test -f "$contract"

grep -q 'canonical_starting_boundary="d8256e8d"' "$contract"
grep -q 'git merge-base --is-ancestor "$canonical_starting_boundary" HEAD' "$contract"
! grep -q 'expected_head="7d9e1d77"' "$contract"

grep -q 'UNSEEDED' "$contract"
grep -q 'NO_EXPLICIT_TEMPERATURE' "$contract"
grep -q 'NO_EXPLICIT_TOP_P' "$contract"
grep -q 'NO_EXPLICIT_TOP_K' "$contract"
grep -q 'ONE_OLLAMA_INVOCATION' "$contract"
grep -q 'DETERMINISTIC_FAIL_CLOSED_VALIDATION_PRESERVED' "$contract"
grep -q '10_SEQUENTIAL_IDENTICAL_INVOCATIONS' "$contract"
grep -q 'NO_RETRY_OF_FAILED_RUN' "$contract"
grep -q 'Do not substitute seeded diagnostic evidence for production evidence.' "$contract"

cat <<'MAP'
MILESTONE=CONVERSATION_ENGINE_GENERATION_STABILITY
PHASE=PRODUCTION_STABILITY_VALIDATION_AND_CLOSURE
CORRIDOR=PRODUCTION_STABILITY_CONTRACT

CANONICAL_STARTING_BOUNDARY=d8256e8d
CONTRACT_ANCESTRY_GUARD=RECONCILED
CONTRACT_SEMANTICS=CURRENT
PRODUCTION_BASELINE=UNCHANGED_UNCONFIGURED_UNSEEDED_GENERATION
VALIDATION_SURFACE=EXISTING_ADAPTIVE_DETAIL_MIXED_CONTENT_LIVE_FIXTURE
SAMPLE_MODE=UNSEEDED_ONLY
SAMPLE_SIZE=10_SEQUENTIAL_IDENTICAL_INVOCATIONS
RETRY_POLICY=NONE
FAIL_CLOSED_CONTRACT=PRESERVED
ONE_OLLAMA_INVOCATION=PRESERVED
SEEDED_DIAGNOSTIC_SUBSTITUTION=PROHIBITED
PRODUCTION_POLICY_CHANGE=NONE
GENERATION_POLICY_CHANGE=NONE
CORRIDOR_1_CLOSURE_READINESS=ESTABLISHED
NEXT_CORRIDOR=UNSEEDED_BEHAVIORAL_VALIDATION
MAP
