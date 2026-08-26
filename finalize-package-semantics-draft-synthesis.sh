#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FINALIZE PACKAGE SEMANTICS LIVING DRAFT SYNTHESIS ==="
echo "EXPECTED_HEAD=643e4fec"
echo "AUTHORIZED_BY=ee2d2495"
echo "IEL_TRANSPORT_CHECKPOINT=643e4fec"
echo "SCOPE=DETERMINISTIC_LIVING_DRAFT_PACKAGE_SEMANTICS_SYNTHESIS_ONLY"

CURRENT_HEAD="$(git rev-parse --short HEAD)"
if [[ "${CURRENT_HEAD}" != "643e4fec" ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== VERIFY SOURCE BOUNDARY ==="
CHANGED_SOURCE_FILES="$(
  git diff --name-only -- \
    scripts/utils/ollamaChat.ts \
    db/matilda-interpretation-runtime.ts \
    server/matilda-chat-workflow.ts \
    db/matilda-draft-synthesis-runtime.ts
)"

if [[ "${CHANGED_SOURCE_FILES}" != "db/matilda-draft-synthesis-runtime.ts" ]]; then
  echo "UNEXPECTED_AUTHORIZED_SOURCE_DIFF"
  printf '%s\n' "${CHANGED_SOURCE_FILES}"
  exit 1
fi

echo "AUTHORIZED_SOURCE_DIFF=DRAFT_SYNTHESIS_ONLY"

echo
echo "=== VERIFY ATOMIC PACKAGE SEMANTICS SELECTION ==="
rg -n \
  'selectedPackageSemantics|packageSemantics|proposedWork|proposedArtifacts|inScope|outOfScope|constraints|expectedOutcome|unresolvedQuestions' \
  db/matilda-draft-synthesis-runtime.ts

echo
echo "=== VERIFY GENERIC DEFAULTS ABSENT ==="
if rg -n \
  'Continue synthesizing interpretation evidence into a reviewable Living Draft Package|A continuously improving Living Draft Package|Interpretation synthesis only|Canonical Package creation, Delegation, Validation, Envelope creation, Routing, Assignment, Cade execution|Remain non-authoritative until explicit operator approval' \
  db/matilda-draft-synthesis-runtime.ts
then
  echo "GENERIC_PACKAGE_DEFAULTS_REMOVED=NO"
  exit 1
fi
echo "GENERIC_PACKAGE_DEFAULTS_REMOVED=YES"

echo
echo "=== VERIFY CURRENT INTERPRETATION PRESERVED ==="
rg -n \
  'matilda_observation|current_interpretation: interpretation' \
  db/matilda-draft-synthesis-runtime.ts

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit --pretty false

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "DRAFT_SYNTHESIS_SUBUNIT_VALIDATED=YES"
echo "ATOMIC_PACKAGE_SEMANTICS_SELECTION=YES"
echo "FIELD_BY_FIELD_CROSS_TURN_MERGE=NO"
echo "GENERIC_DEFAULTS=REMOVED"
echo "CURRENT_INTERPRETATION_SOURCE=PRESERVED"
echo "LIVING_DRAFT_AUTHORITY=NON_AUTHORITATIVE_UNCHANGED"

git add \
  db/matilda-draft-synthesis-runtime.ts \
  implement-package-semantics-draft-synthesis.sh \
  finalize-package-semantics-draft-synthesis.sh
git commit -m "Implement Matilda package semantics draft synthesis"
git push

echo
echo "DRAFT_SYNTHESIS_SUBUNIT_COMMITTED=YES"
echo "NEXT_ACTION=ADD_AND_RUN_FOCUSED_END_TO_END_PACKAGE_SEMANTICS_VALIDATION"
