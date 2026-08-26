#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT EXACT PARSE CALL BEFORE THIRD OBSERVER ATTEMPT ==="
echo "EXPECTED_HEAD_PREFIX=c72540ddf"
echo "RECOVERY_POINT=DR_20260826_111719"
echo "MODE=COLLABORATION"
echo "OBSERVER_IMPLEMENTATION_ATTEMPT_1=FAILED_CONTEXT_SCOPE"
echo "OBSERVER_IMPLEMENTATION_ATTEMPT_2=FAILED_PARSE_CALL_PATTERN_MATCH"
echo "OBSERVER_IMPLEMENTATION_ATTEMPT_3_STARTED=NO"
echo "PRODUCTION_CHANGE=NONE"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != c72540ddf* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== EXACT parseStructuredResponse CALL SITES ==="
rg -n -C 12 -F 'parseStructuredResponse(' scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT OBSERVER REFERENCES ==="
rg -n -C 8 -F 'observeValidatedPackageSemantics' scripts/utils/ollamaChat.ts || true

echo
echo "=== CURRENT PACKAGE SEMANTICS OBSERVER TEST ==="
sed -n '1,180p' scripts/utils/ollamaChat.package-semantics-observer.test.ts

echo
echo "=== FAILURE CONTAINMENT ==="
echo "THIRD_ATTEMPT_ALLOWED_ONLY_IF_EXACT_CALL_SITE_IS_UNAMBIGUOUS=YES"
echo "IF_THIRD_ATTEMPT_FAILS=REVERT_TO_LAST_STABLE_PRE_OBSERVER_SOURCE_STATE"
echo "SPECULATIVE_EDIT=NO"
echo "NEXT_ACTION=BUILD_ATTEMPT_3_ONLY_FROM_EXACT_VERIFIED_CALL_SITE"

git diff --check
