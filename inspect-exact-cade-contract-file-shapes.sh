#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT EXACT CURRENT FILE SHAPES BEFORE CLEAN RETRY ==="
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"

EXPECTED_HEAD_PREFIX="7a420e734"
CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != "${EXPECTED_HEAD_PREFIX}"* ]]; then
  echo "STOP: unexpected HEAD ${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== RUNTIME ENVELOPE PROJECT TARGET ==="
nl -ba server/contracts/execution-envelope.v1.mjs | sed -n '88,132p'

echo
echo "=== DRAFT BUILDER PROJECT TARGET ==="
nl -ba server/execution/build-execution-envelope-draft.mjs | sed -n '72,118p'

echo
echo "=== APPROVAL ARTIFACT ==="
nl -ba server/execution/build-approval-artifact.mjs | sed -n '1,120p'

echo
echo "=== APPROVAL GATE NORMALIZATION / RETURN ==="
nl -ba server/execution/execution-approval-gate.mjs | sed -n '1,180p'

echo
echo "=== STRUCTURAL VALIDATOR ENTRY ==="
nl -ba server/guards/validate-execution-envelope.mjs | sed -n '1,150p'

echo
echo "=== GOVERNANCE VALIDATOR ==="
nl -ba server/execution/governance-validator.mjs | sed -n '1,240p'

echo
echo "=== CONFIRM FAILED ATTEMPT COUNT ==="
echo "FAILED_HYPOTHESIS=EXACT_WHITESPACE_ANCHOR_REPLACEMENT"
echo "FAILED_ATTEMPT_COUNT=1"
echo "RETRY_METHOD_MUST_DIFFER=YES"
echo "NEXT_METHOD=FULL_FILE_REPLACEMENT_FROM_VERIFIED_CURRENT_CONTENT"

echo
echo "=== NEXT ACTION ==="
echo "NEXT_ACTION=BUILD_EXACT_FULL_FILE_REPLACEMENTS_FROM_CURRENT_VERIFIED_SHAPES"
