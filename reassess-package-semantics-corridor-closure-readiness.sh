#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== REASSESS PACKAGE SEMANTICS CORRIDOR CLOSURE READINESS ==="
echo "EXPECTED_HEAD_PREFIX=343f64edd"
echo "VERIFICATION_COMMIT=343f64edd3d7fb9085b71177d091eb6b7b968047"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 343f64edd* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== CONTRACT SURFACE SEARCH ==="
rg -n -C 8 \
  'packageSemantics|package_semantics_json|userPackageSemantics|validateMatildaPackageSemanticsArtifact|enforceMatildaUserPackageSemanticsFidelity' \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts \
  db/matilda-interpretation-runtime.ts \
  db/matilda-draft-synthesis-runtime.ts \
  --glob '!node_modules/**' \
  --glob '!build/**' \
  --glob '!dist/**'

echo
echo "=== PACKAGE SEMANTICS TEST SURFACE ==="
find scripts -maxdepth 3 -type f \
  \( -iname '*package*semantics*test*' -o -iname '*package-semantics*test*' \) \
  -print | sort

echo
echo "=== TODO / GAP / DEFERRED SEARCH ==="
rg -n -i \
  'package semantics.{0,80}(todo|gap|defer|unresolved|not implemented|not established|incomplete|follow.?up)|'\
'(todo|gap|defer|unresolved|not implemented|not established|incomplete|follow.?up).{0,80}package semantics' \
  . \
  --glob '!node_modules/**' \
  --glob '!build/**' \
  --glob '!dist/**' \
  --glob '!*.bak' || true

echo
echo "=== NORMAL CHAT CALLER BOUNDARY ==="
rg -n -C 14 \
  'runMatildaConversationWorkflow|userPackageSemantics|/api/.*matilda|matilda-chat' \
  client src server routes app \
  --glob '!node_modules/**' \
  --glob '!build/**' \
  --glob '!dist/**' 2>/dev/null || true

echo
echo "=== VERIFIED CLOSED SUBSURFACES ==="
echo "STRUCTURED_PACKAGE_SEMANTICS_CONTRACT=IMPLEMENTED"
echo "IEL_TYPED_TRANSPORT=IMPLEMENTED"
echo "LIVING_DRAFT_ATOMIC_DERIVATION=IMPLEMENTED"
echo "OPTION_B_TYPED_INPUT_CONTRACT=IMPLEMENTED"
echo "OPTION_B_RUNTIME_FIDELITY_ENFORCEMENT=IMPLEMENTED_AND_VALIDATED"
echo "UNKNOWN_FIELD_FAIL_CLOSED_PARITY=IMPLEMENTED_AND_VALIDATED"

echo
echo "=== BOUNDARY QUESTIONS ==="
echo "QUESTION_1=IS_ANY_PACKAGE_SEMANTICS_CONTRACT_OR_TRANSPORT_GAP_STILL_EVIDENCED"
echo "QUESTION_2=IS_NORMAL_CHAT_CALLER_TYPED_INPUT_ABSENCE_PART_OF_THIS_CORRIDOR_OR_A_SEPARATE_PRODUCT_INPUT_SURFACE"
echo "QUESTION_3=DO_ANY_TODOS_OR_DEFERRED_ITEMS_BLOCK_CONTRACT_CLOSURE"
echo "QUESTION_4=CAN_CORRIDOR_CLOSE_WITH_GENERAL_UNSEEDED_GENERATION_STABILITY_REMAINING_SEPARATE"
echo "QUESTION_5=CAN_CORRIDOR_CLOSE_WITH_PENDING_APPROVALS_PRESENTATION_REMAINING_SEPARATE"
echo "PACKAGE_SEMANTICS_CORRIDOR_CLOSED=NO"
echo "NEXT_ACTION=CLASSIFY_CLOSURE_READINESS_FROM_REPOSITORY_EVIDENCE_ONLY"

git diff --check
git add reassess-package-semantics-corridor-closure-readiness.sh
git commit -m "Reassess package semantics corridor closure readiness"
git push
