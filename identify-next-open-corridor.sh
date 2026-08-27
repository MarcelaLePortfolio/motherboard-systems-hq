#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IDENTIFY NEXT OPEN CORRIDOR ==="
echo "EXPECTED_HEAD_PREFIX=b9558798f"
echo "PACKAGE_SEMANTICS_CLOSURE_COMMIT=b9558798f62209fcf44f250c5ca8823d4d3753e6"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != b9558798f* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== CLOSED CORRIDOR ==="
echo "PACKAGE_SEMANTICS_CORRIDOR=CLOSED"

echo
echo "=== PRESERVED SEPARATE WORK ==="
echo "GENERAL_UNSEEDED_GENERATION_STABILITY=SEPARATE"
echo "NORMAL_CHAT_UI_TYPED_INPUT_SURFACE=SEPARATE_OPTIONAL_PRODUCT_CAPABILITY"
echo "PENDING_APPROVALS_PRESENTATION_REFINEMENT=SEPARATE"
echo "SIDEBAR_COMPACTNESS=SEPARATE_PRESENTATION_FOLLOWUP"

echo
echo "=== PARENT MAP EVIDENCE SEARCH ==="
rg -n -i \
  'milestone|phase|corridor|package semantics|pending decisions|approvals|generation stability|next corridor|active corridor|closed corridor' \
  . \
  --glob '!node_modules/**' \
  --glob '!build/**' \
  --glob '!dist/**' \
  --glob '!*.bak' \
  | sed -n '1,420p'

echo
echo "=== RECENT CORRIDOR / PHASE COMMITS ==="
git log --oneline --decorate -80 \
  | grep -Ei 'corridor|phase|milestone|package semantics|approvals|pending decisions|generation stability' \
  || true

echo
echo "=== DETERMINATION BOUNDARY ==="
echo "NEXT_OPEN_CORRIDOR=NOT_YET_CLASSIFIED"
echo "NO_AUTOMATIC_IMPLEMENTATION=YES"
echo "NEXT_ACTION=CLASSIFY_PARENT_MILESTONE_MAP_AND_NEXT_OPEN_CORRIDOR_FROM_REPOSITORY_EVIDENCE"

git diff --check
git add identify-next-open-corridor.sh
git commit -m "Identify next open corridor evidence"
git push
