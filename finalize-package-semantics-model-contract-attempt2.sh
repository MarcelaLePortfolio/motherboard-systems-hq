#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FINALIZE PACKAGE SEMANTICS MODEL CONTRACT ATTEMPT 2 ==="
echo "EXPECTED_HEAD=8e637105"
echo "AUTHORIZED_BY=ee2d2495"
echo "FAILED_IMPLEMENTATION_ATTEMPTS_BEFORE_THIS=1"

CURRENT_HEAD="$(git rev-parse --short HEAD)"
if [[ "${CURRENT_HEAD}" != "8e637105" ]]; then
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

if [[ "${CHANGED_SOURCE_FILES}" != "scripts/utils/ollamaChat.ts" ]]; then
  echo "UNEXPECTED_AUTHORIZED_SOURCE_DIFF"
  printf '%s\n' "${CHANGED_SOURCE_FILES}"
  exit 1
fi

echo "AUTHORIZED_SOURCE_DIFF=OLLAMA_CHAT_ONLY"

echo
echo "=== VERIFY PACKAGE SEMANTICS CONTRACT ==="
rg -n \
  'packageSemantics|MatildaPackageSemanticsArtifact|validateMatildaPackageSemanticsArtifact|structured response without package semantics|Do not use generic Living Draft process language' \
  scripts/utils/ollamaChat.ts

echo
echo "=== TYPECHECK ==="
npx tsc --noEmit --pretty false

echo
echo "=== DIFF CHECK ==="
git diff --check

echo
echo "MODEL_CONTRACT_SUBUNIT_VALIDATED=YES"
echo "IEL_TRANSPORT_IMPLEMENTED=NO"
echo "DRAFT_SYNTHESIS_IMPLEMENTED=NO"
echo "NEXT_ACTION=COMMIT_STABLE_MODEL_CONTRACT_SUBUNIT"

git add \
  scripts/utils/ollamaChat.ts \
  implement-package-semantics-model-contract-attempt2.sh \
  finalize-package-semantics-model-contract-attempt2.sh

git commit -m "Implement Matilda package semantics model contract"
git push

echo
echo "MODEL_CONTRACT_SUBUNIT_COMMITTED=YES"
echo "NEXT_ACTION=IMPLEMENT_IEL_PACKAGE_SEMANTICS_TRANSPORT_FROM_THIS_STABLE_CHECKPOINT"
