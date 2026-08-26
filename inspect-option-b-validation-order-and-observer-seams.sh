#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT OPTION B VALIDATION ORDER AND OBSERVER SEAMS ==="
echo "EXPECTED_HEAD_PREFIX=b8cb1b6bf"
echo "LIVE_VALIDATION_COMMIT=68622368951081208162d0d9c8f69e150e1380d2"
echo "CLASSIFICATION_COMMIT=b8cb1b6bf2431caef80d372a96264c6a6c170fbd"
echo "MODE=COLLABORATION"
echo "NEW_OLLAMA_INVOCATION=NO"
echo "SOURCE_IMPLEMENTATION_CHANGE=NO"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != b8cb1b6bf* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== OBSERVER SURFACES ==="
rg -n -C 12 \
  'observeValidatedPackageSemantics|observeValidatedSelectedContextSegments|packageSemantics' \
  scripts/utils/ollamaChat.ts

echo
echo "=== POST-PARSE VALIDATION ORDER ==="
rg -n -C 35 \
  'parseStructuredResponse|enforceMatildaUserPackageSemanticsFidelity|observeValidatedPackageSemantics|selectedContextSegments|supportSourceReferences' \
  scripts/utils/ollamaChat.ts

echo
echo "=== EXACT PARSE-THROUGH-RETURN REGION ==="
PARSE_LINE="$(rg -n 'parseStructuredResponse\(rawResponse\)' scripts/utils/ollamaChat.ts | head -1 | cut -d: -f1)"
if [[ -z "${PARSE_LINE}" ]]; then
  echo "PARSE_CALL_NOT_FOUND"
  exit 1
fi
START=$((PARSE_LINE > 20 ? PARSE_LINE - 20 : 1))
END=$((PARSE_LINE + 180))
sed -n "${START},${END}p" scripts/utils/ollamaChat.ts

echo
echo "=== OBSERVER TEST EVIDENCE ==="
sed -n '1,180p' scripts/utils/ollamaChat.package-semantics-observer.test.ts

echo
echo "=== LIVE RUNNER EVIDENCE ==="
sed -n '1,180p' scripts/run-option-b-live-validation.ts

echo
echo "=== INVESTIGATION QUESTIONS ==="
echo "QUESTION_1=DOES_PACKAGE_SEMANTICS_VALIDATION_OCCUR_BEFORE_SELECTED_CONTEXT_FAIL_CLOSED"
echo "QUESTION_2=DOES_OPTION_B_FIDELITY_ENFORCEMENT_OCCUR_BEFORE_SELECTED_CONTEXT_FAIL_CLOSED"
echo "QUESTION_3=DOES_EXISTING_PACKAGE_SEMANTICS_OBSERVER_FIRE_BEFORE_SELECTED_CONTEXT_FAIL_CLOSED"
echo "QUESTION_4=COULD_EXISTING_OBSERVER_EVIDENCE_PROVE_EXACT_TYPED_VALUE_WITHOUT_NEW_OLLAMA_INVOCATION"
echo "QUESTION_5=WOULD_ANSWERING_QUESTION_4_REQUIRE_ONLY_TEST_OR_RUNNER_OBSERVATION_RATHER_THAN_RUNTIME_SEMANTIC_CHANGE"
echo "NEXT_ACTION=CLASSIFY_FROM_OUTPUT_ONLY"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "SECOND_LIVE_INVOCATION_AUTHORIZED=NO"

git diff --check

git add inspect-option-b-validation-order-and-observer-seams.sh
git commit -m "Inspect Option B validation order and observer seams"
git push
