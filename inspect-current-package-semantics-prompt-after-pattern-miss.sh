#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT CURRENT PACKAGE SEMANTICS PROMPT AFTER PATTERN MISS ==="
echo "EXPECTED_HEAD_PREFIX=adf96eee6"
echo "RECOVERY_POINT=DR_20260826_111719"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_ATTEMPT=1_FAILED_MECHANICALLY"
echo "IMPLEMENTATION_ATTEMPT_2_STARTED=NO"
echo "PRODUCTION_CHANGE=NONE"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != adf96eee6* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== EXACT CURRENT PACKAGE SEMANTICS PROMPT REGION ==="
sed -n '1054,1078p' scripts/utils/ollamaChat.ts

echo
echo "=== EXACT CURRENT FOCUSED TEST REGION ==="
sed -n '108,145p' scripts/utils/ollamaChat.package-semantics-contract.test.ts

echo
echo "=== DECISION BOUNDARY ==="
echo "SOURCE_EDIT=NONE"
echo "NEXT_ACTION=BUILD_SECOND_EDIT_AGAINST_EXACT_TEXT_ONLY_IF_MATCH_IS_UNAMBIGUOUS"
