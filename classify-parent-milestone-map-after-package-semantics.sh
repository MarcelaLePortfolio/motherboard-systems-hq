#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY PARENT MILESTONE MAP AFTER PACKAGE SEMANTICS ==="
echo "EXPECTED_HEAD_PREFIX=e7eb5bf0d"
echo "PACKAGE_SEMANTICS_CORRIDOR=CLOSED"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != e7eb5bf0d* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== STRONGEST CURRENT PARENT-MAP CANDIDATE ==="
echo "CANDIDATE_PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "EVIDENCED_CORRIDOR=PACKAGE_HANDOFF_CONTRACT"
echo "EVIDENCED_SUCCESSOR=PROJECT_BOUND_HANDOFF"
echo "CLASSIFICATION_NOT_YET_FINAL=YES"

echo
echo "=== AUTHORITATIVE MISSION PACKAGE HANDOFF EVIDENCE ==="
for file in \
  define-minimum-package-handoff-contract-semantics.sh \
  investigate-governance-runtime-handoff-ownership.sh \
  close-package-handoff-contract-corridor.sh
do
  if [[ -f "${file}" ]]; then
    echo
    echo "--- ${file} ---"
    sed -n '1,140p' "${file}"
  fi
done

echo
echo "=== PROJECT-BOUND HANDOFF EVIDENCE ==="
rg -n -C 12 \
  'PROJECT_BOUND_HANDOFF|Project Bound Handoff|project-bound handoff|project bound handoff' \
  . \
  --glob '!node_modules/**' \
  --glob '!build/**' \
  --glob '!dist/**' \
  --glob '!*.bak' \
  | sed -n '1,320p' || true

echo
echo "=== PACKAGE SEMANTICS RELATION TO PARENT MAP ==="
rg -n -C 12 \
  'PACKAGE_SEMANTICS|Package Semantics|MATILDA_PACKAGE_SEMANTICS_END_TO_END_TRANSPORT' \
  *handoff* *package* *milestone* *corridor* 2>/dev/null \
  | sed -n '1,360p' || true

echo
echo "=== RELEVANT RECENT HISTORY BEFORE PACKAGE SEMANTICS ==="
git log --oneline --decorate --all -180 \
  | grep -Ei \
    'handoff|project.bound|package handoff|package semantics|approvals|operational package|authority' \
  | sed -n '1,220p' || true

echo
echo "=== CLASSIFICATION QUESTIONS ==="
echo "QUESTION_1=IS_PACKAGE_SEMANTICS_A_CHILD_OR_SUPPORTING_CORRIDOR_WITHIN_AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "QUESTION_2=HAD_PACKAGE_HANDOFF_CONTRACT_ALREADY_CLOSED_BEFORE_PACKAGE_SEMANTICS_WORK_BEGAN"
echo "QUESTION_3=IS_PROJECT_BOUND_HANDOFF_STILL_THE_NEXT_OPEN_CANONICAL_CORRIDOR"
echo "QUESTION_4=DOES_ANY_NEWER_MAP_SUPERSEDE_PROJECT_BOUND_HANDOFF"
echo "QUESTION_5=ARE_APPROVALS_REFINEMENT_AND_SIDEBAR_COMPACTNESS_DEFERRED_PRESENTATION_WORK_RATHER_THAN_CANONICAL_NEXT_CORRIDORS"

echo
echo "=== DECISION BOUNDARY ==="
echo "NEXT_OPEN_CORRIDOR=NOT_YET_FINALIZED"
echo "PROJECT_BOUND_HANDOFF=CURRENT_STRONGEST_CANDIDATE"
echo "AUTOMATIC_ENTRY_INTO_NEXT_CORRIDOR=NO"
echo "NEXT_ACTION=CLASSIFY_CANONICAL_PARENT_PHASE_AND_NEXT_OPEN_CORRIDOR_FROM_THIS_NARROW_EVIDENCE"

git diff --check
git add classify-parent-milestone-map-after-package-semantics.sh
git commit -m "Classify parent map after package semantics"
git push
