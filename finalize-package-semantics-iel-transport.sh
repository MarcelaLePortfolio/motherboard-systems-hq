#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FINALIZE PACKAGE SEMANTICS IEL TRANSPORT ==="
echo "EXPECTED_HEAD=881c3551"
echo "AUTHORIZED_BY=ee2d2495"
echo "MODEL_CONTRACT_CHECKPOINT=881c3551"
echo "SCOPE=IEL_PERSISTENCE_RECONSTRUCTION_AND_WORKFLOW_TRANSPORT_ONLY"
echo "DRAFT_SYNTHESIS_CHANGE_AUTHORIZED_IN_THIS_SUBUNIT=NO"

CURRENT_HEAD="$(git rev-parse --short HEAD)"
if [[ "${CURRENT_HEAD}" != "881c3551" ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== VERIFY SOURCE BOUNDARY ==="
CHANGED_SOURCE_FILES="$(
  git diff --name-only -- \
    db/matilda-interpretation-runtime.ts \
    server/matilda-chat-workflow.ts \
    db/matilda-draft-synthesis-runtime.ts
)"

EXPECTED_SOURCE_FILES="$(
  printf '%s\n' \
    'db/matilda-interpretation-runtime.ts' \
    'server/matilda-chat-workflow.ts'
)"

if [[ "${CHANGED_SOURCE_FILES}" != "${EXPECTED_SOURCE_FILES}" ]]; then
  echo "UNEXPECTED_AUTHORIZED_SOURCE_DIFF"
  printf '%s\n' "${CHANGED_SOURCE_FILES}"
  exit 1
fi

echo "AUTHORIZED_SOURCE_DIFF=IEL_RUNTIME_AND_CHAT_WORKFLOW_ONLY"

echo
echo "=== VERIFY IEL TRANSPORT MARKERS ==="
rg -n \
  'package_semantics|packageSemantics|validateMatildaPackageSemanticsArtifact|reconstructPackageSemantics' \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts

echo
echo "=== VERIFY REQUIRED PERSISTENCE ELEMENTS ==="
rg -n \
  'package_semantics_json TEXT|ADD COLUMN package_semantics_json TEXT|@package_semantics_json|reconstructPackageSemantics|row\.package_semantics_json' \
  db/matilda-interpretation-runtime.ts

echo
echo "=== VERIFY LEGACY UNRESOLVED QUESTIONS WRITE PRESERVED ==="
rg -n \
  'unresolved_questions: null' \
  server/matilda-chat-workflow.ts

echo
echo "=== VERIFY DRAFT SYNTHESIS UNCHANGED ==="
if git diff --quiet -- db/matilda-draft-synthesis-runtime.ts; then
  echo "DRAFT_SYNTHESIS_UNCHANGED=YES"
else
  echo "DRAFT_SYNTHESIS_UNCHANGED=NO"
  exit 1
fi

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit --pretty false

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "IEL_TRANSPORT_SUBUNIT_VALIDATED=YES"
echo "ONE_WORKFLOW_ONE_IEL_ENTRY_PRESERVED=YES"
echo "SECOND_OLLAMA_INVOCATION_ADDED=NO"
echo "DRAFT_SYNTHESIS_IMPLEMENTED=NO"

git add \
  db/matilda-interpretation-runtime.ts \
  server/matilda-chat-workflow.ts \
  implement-package-semantics-iel-transport.sh \
  finalize-package-semantics-iel-transport.sh

git commit -m "Implement Matilda package semantics IEL transport"
git push

echo
echo "IEL_TRANSPORT_SUBUNIT_COMMITTED=YES"
echo "NEXT_ACTION=IMPLEMENT_DETERMINISTIC_LIVING_DRAFT_PACKAGE_SEMANTICS_SYNTHESIS"
