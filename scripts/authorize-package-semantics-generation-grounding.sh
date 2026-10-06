#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="9e5581557"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"

echo "============================================================"
echo "AUTHORIZATION GATE — PACKAGE SEMANTICS GENERATION GROUNDING"
echo "============================================================"
echo
echo "ROOT_CAUSE_CLASSIFIED=YES"
echo "FAILURE_BOUNDARY=UPSTREAM_PACKAGE_SEMANTICS_GENERATION"
echo "EXISTING_FIDELITY_GUARD_CORRECT=YES"
echo
echo "AUTHORIZED_IMPLEMENTATION_SCOPE:"
echo "- Ground model-authored expectedOutcome in the current concrete operation."
echo "- Require preservation of requested operation direction."
echo "- Keep preservation constraints distinct from the requested outcome."
echo "- Preserve the existing fail-closed fidelity guard."
echo
echo "OUT_OF_SCOPE:"
echo "- Fidelity guard relaxation or removal"
echo "- Parser changes"
echo "- Schema changes"
echo "- Authority-model changes"
echo "- Unrelated worktree changes"
echo "- Live dogfood retry before implementation validation"
echo
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo
echo "REPLY EXACTLY:"
echo "I authorize narrow Package Semantics generation grounding implementation."
