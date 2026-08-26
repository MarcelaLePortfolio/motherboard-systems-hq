#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INVESTIGATE PACKAGE SEMANTICS VALUE FIDELITY CONTRACT ==="
echo "EXPECTED_HEAD_PREFIX=9436e8650"
echo "RECOVERY_POINT=DR_20260826_111719"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 9436e8650* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== CURRENT PROMPT RULES ==="
rg -n -C 8 \
  'explicitly establishes|preserve that request-specific information|package-semantic field|expectedOutcome' \
  scripts/utils/ollamaChat.ts

echo
echo "=== PACKAGE SEMANTICS VALIDATOR ==="
sed -n '360,440p' scripts/utils/ollamaChat.ts

echo
echo "=== PACKAGE SEMANTICS CONTRACT TESTS ==="
sed -n '1,260p' scripts/utils/ollamaChat.package-semantics-contract.test.ts

echo
echo "=== FIXED-SEED VALIDATION INPUT ==="
sed -n '1,130p' scripts/validate-package-semantics-authorship-fixed-seed-live.ts

echo
echo "=== VERIFIED CLASSIFICATION ==="
echo "EXPLICIT_FIELD_WAS_NON_NULL=YES"
echo "EXPLICIT_EXPECTED_OUTCOME_MEANING_WAS_PRESERVED=NO"
echo "MODEL_SUBSTITUTED_HIGHER_LEVEL_REQUEST_FRAMING=YES"
echo "NON_NULL_COMPLETENESS_ALONE_IS_INSUFFICIENT=YES"
echo "CURRENT_RUNTIME_VALIDATOR_CHECKS_TYPE_AND_NON_EMPTY_VALUE_NOT_SEMANTIC_EQUIVALENCE=YES"
echo "DETERMINISTIC_VALUE_FIDELITY_ENFORCEMENT_CURRENTLY_EXISTS=NO"

echo
echo "=== DESIGN QUESTION ==="
echo "QUESTION=SHOULD_CONDITIONAL_COMPLETENESS_REQUIRE_SEMANTIC_FIDELITY_TO_EXPLICIT_USER_SUPPLIED_FIELD_VALUES"
echo "PROMPT_ONLY_STRENGTHENING_MAY_REDUCE_BUT_NOT_DETERMINISTICALLY_ELIMINATE_SUBSTITUTION=YES"
echo "HEURISTIC_EXTRACTION_AUTHORIZED=NO"
echo "SECOND_OLLAMA_INVOCATION_AUTHORIZED=NO"
echo "STRUCTURED_USER_INPUT_SIGNAL_EXISTS=UNKNOWN_PENDING_EVIDENCE"
echo "NEXT_ACTION=CLASSIFY_NARROWEST_ARCHITECTURALLY_VALID_VALUE_FIDELITY_MECHANISM_BEFORE_ANY_IMPLEMENTATION"

git diff --check

git add investigate-package-semantics-value-fidelity-contract.sh
git commit -m "Investigate package semantics value fidelity contract"
git push
