#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="a62ca58b0"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

git fetch origin "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

echo "=== ATTEMPT 2 CLOSED AS FAILED ==="
echo "ATTEMPT_2_STATIC_VALIDATION=PASS"
echo "ATTEMPT_2_LIVE_VALIDATION=FAIL"
echo "FAILURE_CLASS=UPSTREAM_MODEL_GENERATION_DIRECTION_AND_SUBJECT_SUBSTITUTION"
echo "FIDELITY_GUARD=CORRECT_FAIL_CLOSED"
echo "LIVE_RETRY_AUTHORIZED=NO"

echo
echo "=== ATTEMPT 3 PROPOSED HYPOTHESIS ==="
echo "HYPOTHESIS=DETERMINISTIC_CURRENT_REQUEST_GROUNDING_BEFORE_MODEL_GENERATION"
echo "GOAL=Anchor Package Semantics generation to the current concrete operation and subject before model generation so retrieved or historical package concepts cannot replace them."

echo
echo "IN_SCOPE:"
echo "- derive bounded current-request operation and subject grounding from the current user request"
echo "- present that grounding to the existing semantic generation invocation"
echo "- preserve preservation requirements as constraints"
echo "- retain the existing fidelity guard unchanged"
echo "- add focused regression coverage"

echo
echo "OUT_OF_SCOPE:"
echo "- relaxing or removing the fidelity guard"
echo "- parser changes"
echo "- output schema changes"
echo "- authority-model changes"
echo "- unrelated worktree changes"
echo "- live dogfood before static validation and fresh runtime certification"

echo
echo "ATTEMPT_3_AUTHORIZED=NO"
echo "NO_SOURCE_MUTATION_PERFORMED=YES"

echo
echo "=== AUTHORIZATION REQUIRED ==="
echo "I authorize Attempt 3 deterministic current-request Package Semantics grounding implementation."
