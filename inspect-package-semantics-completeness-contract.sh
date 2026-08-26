#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT PACKAGE SEMANTICS COMPLETENESS CONTRACT ==="
echo "EXPECTED_HEAD_PREFIX=59f4e4341"
echo "RECOVERY_POINT=DR_20260826_111719"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 59f4e4341* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== MODEL CONTRACT ==="
rg -n -C 10 \
  'packageSemantics|expectedOutcome|proposedWork|unresolvedQuestions|validateMatildaPackageSemanticsArtifact' \
  scripts/utils/ollamaChat.ts \
  | head -260

echo
echo "=== PACKAGE SEMANTICS TEST CONTRACT ==="
rg -n -C 8 \
  'expectedOutcome|null|nullable|Package Semantics validator|packageSemantics' \
  scripts/utils/ollamaChat.package-semantics-contract.test.ts \
  | head -260

echo
echo "=== PROMPT AUTHORSHIP CONTRACT ==="
rg -n -C 10 \
  'Package Semantics|expected outcome|expectedOutcome|null|request-specific' \
  scripts/utils/ollamaChat.ts \
  | head -260

echo
echo "=== CLASSIFICATION TARGET ==="
echo "QUESTION_1=DOES_THE_SCHEMA_REQUIRE_THE_FIELD_BUT_ALLOW_NULL"
echo "QUESTION_2=DOES_THE_RUNTIME_VALIDATOR_ALLOW_NULL_FOR_expectedOutcome"
echo "QUESTION_3=DOES_THE_PROMPT_EXPLICITLY_ALLOW_NULL_WHEN_THE_USER_PROVIDED_AN_EXPECTED_OUTCOME"
echo "QUESTION_4=WOULD_REQUIRING_NON_NULL_expectedOutcome_FOR_EVERY_NON_NULL_ARTIFACT_BE_SEMANTICALLY_SAFE"
echo "QUESTION_5=SHOULD_COMPLETENESS_INSTEAD_BE_CONDITIONAL_ON_INFORMATION_PRESENT_IN_THE_CURRENT_REQUEST"
echo "NEXT_ACTION=DECIDE_CONTRACT_CHANGE_ONLY_AFTER_THE_CURRENT_SCHEMA_VALIDATOR_PROMPT_AND_TEST_BOUNDARIES_ARE_VISIBLE"

git add inspect-package-semantics-completeness-contract.sh
git commit -m "Inspect package semantics completeness contract"
git push
./inspect-package-semantics-completeness-contract.sh
