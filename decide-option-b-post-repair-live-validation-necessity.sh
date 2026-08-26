#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== DECIDE OPTION B POST-REPAIR LIVE VALIDATION NECESSITY ==="
echo "EXPECTED_HEAD_PREFIX=e059476db"
echo "VERIFICATION_COMMIT=e059476dbb0382bb605790bceae9f8ba5276a839"
echo "IMPLEMENTATION_COMMIT=8ff26b3e3e535b01121c564d4245e70a0b44c7ae"
echo "MODE=COLLABORATION"
echo "PRODUCTION_CHANGE=NONE"
echo "LIVE_OLLAMA_INVOCATION_AUTHORIZED=NO"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != e059476db* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

cat > OPTION_B_POST_REPAIR_LIVE_VALIDATION_DECISION.md << 'DECISION'
# Option B Post-Repair Live Validation Decision

## Verified State

The runtime integration defect is repaired.

The verified evidence establishes:

- one runtime call to `enforceMatildaUserPackageSemanticsFidelity`;
- placement after structured-response parsing;
- placement before `observeValidatedPackageSemantics`;
- placement before selected-context provenance validation;
- exact typed match passes;
- mismatch fails before observer and selected-context rejection;
- null Package Semantics fails before observer;
- absent and null typed inputs preserve existing behavior;
- one Ollama invocation is preserved;
- focused runtime integration tests pass;
- direct fidelity tests pass;
- Package Semantics and observer regressions pass;
- lifecycle regressions pass;
- typecheck, build, and diff check pass.

## Decision

A second live Ollama invocation is **not required to establish the deterministic Option B runtime fidelity mechanism itself**.

The mechanism is already directly exercised through the `ollamaChat` runtime path using controlled runtime-level tests that verify both success and fail-closed ordering.

A new live model invocation would test model-generation behavior against the mechanism, not whether the mechanism is wired and functioning.

That distinction matters because unseeded model generation remains separately unstable and the prior live run was blocked by an unrelated selected-context provenance failure.

## Boundary

Therefore:

- Option B typed-input runtime fidelity implementation may be considered validated at the deterministic runtime-contract level.
- Do not use a new live invocation as a prerequisite for Option B mechanism closure.
- Do not claim general unseeded production generation stability.
- Do not claim end-to-end normal-chat UX exercises typed input unless an actual caller supplies `userPackageSemantics`.
- Do not close the broader Package Semantics corridor while the separately identified unknown-field validator gap remains unresolved.

## Next Action

Investigate and resolve the Package Semantics unknown-field validator gap before considering broader Package Semantics corridor closure.

This decision does not authorize that implementation automatically.
DECISION

echo
echo "=== DECISION ==="
echo "POST_REPAIR_LIVE_VALIDATION_REQUIRED_FOR_OPTION_B_RUNTIME_MECHANISM=NO"
echo "OPTION_B_DETERMINISTIC_RUNTIME_FIDELITY_VALIDATED=YES"
echo "OPTION_B_RUNTIME_INTEGRATION_DEFECT=REPAIRED"
echo "NEW_LIVE_OLLAMA_RUN_AUTHORIZED=NO"
echo "GENERAL_UNSEEDED_GENERATION_STABILITY_ESTABLISHED=NO"
echo "NORMAL_CHAT_CALLER_TYPED_INPUT_PATH_ESTABLISHED=NO"
echo "UNKNOWN_FIELD_PACKAGE_SEMANTICS_VALIDATOR_GAP=UNRESOLVED"
echo "PACKAGE_SEMANTICS_CORRIDOR_CLOSED=NO"
echo "NEXT_ACTION=INVESTIGATE_UNKNOWN_FIELD_PACKAGE_SEMANTICS_VALIDATOR_GAP"

git diff --check

git add \
  OPTION_B_POST_REPAIR_LIVE_VALIDATION_DECISION.md \
  decide-option-b-post-repair-live-validation-necessity.sh
git commit -m "Decide Option B post-repair live validation necessity"
git push
