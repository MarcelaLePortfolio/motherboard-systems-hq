#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT PACKAGE SEMANTICS LIVING DRAFT SYNTHESIS ==="
echo "EXPECTED_HEAD=643e4fec"
echo "AUTHORIZED_BY=ee2d2495"
echo "SCOPE=DETERMINISTIC_LIVING_DRAFT_PACKAGE_SEMANTICS_SYNTHESIS_ONLY"
echo "AUTHORITY_MODEL_CHANGE=NO"
echo "SECOND_OLLAMA_INVOCATION=NO"
echo "HEURISTIC_EXTRACTION=NO"

CURRENT_HEAD="$(git rev-parse --short HEAD)"
if [[ "${CURRENT_HEAD}" != "643e4fec" ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

python3 - << 'PY'
from pathlib import Path

path = Path("db/matilda-draft-synthesis-runtime.ts")
text = path.read_text()

old = '''  const unresolved = evidence

    .map((entry: any) => entry.unresolved_questions)

    .filter(Boolean)

    .join("\\n");

  return upsertLivingDraftPackage({
'''

new = '''  const selectedPackageSemantics = evidence

    .find((entry: any) => entry.packageSemantics !== null)

    ?.packageSemantics ?? null;

  return upsertLivingDraftPackage({
'''

count = text.count(old)
if count != 1:
    raise SystemExit(
        f"STOP_PACKAGE_SEMANTICS_SELECTION_EXPECTED_1_FOUND_{count}"
    )

text = text.replace(old, new, 1)

old = '''    proposed_work:

      "Continue synthesizing interpretation evidence into a reviewable Living Draft Package.",

    proposed_artifacts:

      "Living Draft Package",

    in_scope:

      "Interpretation synthesis only.",

    out_of_scope:

      "Canonical Package creation, Delegation, Validation, Envelope creation, Routing, Assignment, Cade execution.",

    constraints:

      "Remain non-authoritative until explicit operator approval.",

    expected_outcome:

      "A continuously improving Living Draft Package.",

    unresolved_questions: unresolved,
'''

new = '''    proposed_work:

      selectedPackageSemantics?.proposedWork ?? null,

    proposed_artifacts:

      selectedPackageSemantics?.proposedArtifacts ?? null,

    in_scope:

      selectedPackageSemantics?.inScope ?? null,

    out_of_scope:

      selectedPackageSemantics?.outOfScope ?? null,

    constraints:

      selectedPackageSemantics?.constraints ?? null,

    expected_outcome:

      selectedPackageSemantics?.expectedOutcome ?? null,

    unresolved_questions:

      selectedPackageSemantics?.unresolvedQuestions ?? null,
'''

count = text.count(old)
if count != 1:
    raise SystemExit(
        f"STOP_GENERIC_DEFAULT_REPLACEMENT_EXPECTED_1_FOUND_{count}"
    )

text = text.replace(old, new, 1)
path.write_text(text)
PY

echo
echo "=== VERIFY PACKAGE SEMANTICS SELECTION ==="
rg -n \
  'selectedPackageSemantics|packageSemantics|proposedWork|proposedArtifacts|inScope|outOfScope|expectedOutcome|unresolvedQuestions' \
  db/matilda-draft-synthesis-runtime.ts

echo
echo "=== VERIFY GENERIC DEFAULTS REMOVED ==="
if rg -n \
  'Continue synthesizing interpretation evidence into a reviewable Living Draft Package|A continuously improving Living Draft Package|Interpretation synthesis only|Living Draft Package' \
  db/matilda-draft-synthesis-runtime.ts
then
  echo "GENERIC_PACKAGE_DEFAULTS_REMOVED=NO"
  exit 1
else
  echo "GENERIC_PACKAGE_DEFAULTS_REMOVED=YES"
fi

echo
echo "=== VERIFY CURRENT INTERPRETATION PRESERVED ==="
rg -n \
  'matilda_observation|current_interpretation: interpretation' \
  db/matilda-draft-synthesis-runtime.ts

echo
echo "=== VERIFY ONLY DRAFT SYNTHESIS SOURCE CHANGED ==="
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
echo "=== TYPECHECK ==="
npx tsc --noEmit --pretty false

echo
echo "=== DIFF CHECK ==="
git diff --check
git diff -- db/matilda-draft-synthesis-runtime.ts

echo
echo "DRAFT_SYNTHESIS_SUBUNIT_VALIDATED=YES"
echo "ATOMIC_PACKAGE_SEMANTICS_SELECTION=YES"
echo "FIELD_BY_FIELD_CROSS_TURN_MERGE=NO"
echo "GENERIC_DEFAULTS=REMOVED"
echo "LIVING_DRAFT_AUTHORITY=NON_AUTHORITATIVE_UNCHANGED"

git add \
  implement-package-semantics-draft-synthesis.sh \
  db/matilda-draft-synthesis-runtime.ts

git commit -m "Implement Matilda package semantics draft synthesis"
git push

echo
echo "DRAFT_SYNTHESIS_SUBUNIT_COMMITTED=YES"
echo "NEXT_ACTION=ADD_AND_RUN_FOCUSED_PACKAGE_SEMANTICS_TESTS"
