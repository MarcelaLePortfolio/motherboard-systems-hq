#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== CLASSIFY CANONICAL PARENT PHASE AFTER PACKAGE SEMANTICS ==="
echo "EXPECTED_HEAD_PREFIX=f0ca2efeb"
echo "PACKAGE_SEMANTICS_CORRIDOR=CLOSED"
echo "MODE=COLLABORATION"
echo "IMPLEMENTATION_AUTHORIZED=NO"
echo "PRODUCTION_CHANGE=NONE"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != f0ca2efeb* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

echo
echo "=== IMPORTANT RECONCILIATION ==="
echo "PROJECT_BOUND_HANDOFF_WAS_PREVIOUSLY_IDENTIFIED_AS_SUCCESSOR_TO_PACKAGE_HANDOFF_CONTRACT=YES"
echo "PROJECT_BOUND_HANDOFF_IS_CURRENTLY_OPEN=NOT_ESTABLISHED"
echo "EVIDENCE_NOW_SHOWS_A_FORMAL_PROJECT_BOUND_HANDOFF_CLOSURE_ARTIFACT=YES"
echo "EVIDENCE_ALSO_SHOWS_MISSION_CONTROL_INTAKE_IMPLEMENTATION_COMPLETE=YES"
echo "RECENT_HISTORY_SHOWS_AUTHORITATIVE_MISSION_PACKAGE_HANDOFF_PHASE_CLOSURE_COMMIT=YES"
echo "THEREFORE_PROJECT_BOUND_HANDOFF_MUST_NOT_BE_ASSUMED_NEXT_OPEN_CORRIDOR=YES"

echo
echo "=== PROJECT-BOUND HANDOFF FORMAL CLOSURE ==="
if [[ -f close-project-bound-handoff-corridor.sh ]]; then
  sed -n '1,140p' close-project-bound-handoff-corridor.sh
else
  echo "close-project-bound-handoff-corridor.sh=NOT_FOUND"
fi

echo
echo "=== MISSION CONTROL INTAKE STATE ==="
for file in \
  classify-mission-control-intake-closure-readiness.sh \
  close-mission-control-intake-corridor.sh
do
  if [[ -f "${file}" ]]; then
    echo
    echo "--- ${file} ---"
    sed -n '1,150p' "${file}"
  fi
done

echo
echo "=== HANDOFF VALIDATION / PHASE CLOSURE STATE ==="
for file in \
  classify-handoff-validation-and-phase-closure-scope.sh \
  classify-end-to-end-handoff-validation-and-phase-closure-criteria.sh \
  close-handoff-validation-and-phase-closure-corridor.sh
do
  if [[ -f "${file}" ]]; then
    echo
    echo "--- ${file} ---"
    sed -n '1,170p' "${file}"
  fi
done

echo
echo "=== FORMAL PHASE CLOSURE EVIDENCE ==="
PHASE_CLOSE_COMMIT="$(git log --format='%H %s' --all --grep='Close Authoritative Mission Package Handoff phase' -1 || true)"
echo "PHASE_CLOSE_COMMIT=${PHASE_CLOSE_COMMIT:-NOT_FOUND}"

if [[ -n "${PHASE_CLOSE_COMMIT}" ]]; then
  PHASE_CLOSE_SHA="${PHASE_CLOSE_COMMIT%% *}"
  git show \
    --stat \
    --oneline \
    --decorate \
    --no-renames \
    "${PHASE_CLOSE_SHA}"

  echo
  echo "=== PHASE CLOSURE COMMIT CONTENT MARKERS ==="
  git show --format= --no-ext-diff "${PHASE_CLOSE_SHA}" \
    | grep -Ei \
      'PHASE|CORRIDOR|CLOSED|NEXT|MILESTONE|MISSION_CONTROL|HANDOFF' \
    | sed -n '1,260p' || true
fi

echo
echo "=== PHASE DR CHECKPOINT ==="
PHASE_DR_COMMIT="$(git log --format='%H %s' --all --grep='Authoritative Mission Package Handoff phase DR checkpoint' -1 || true)"
echo "PHASE_DR_COMMIT=${PHASE_DR_COMMIT:-NOT_FOUND}"

if [[ -n "${PHASE_DR_COMMIT}" ]]; then
  PHASE_DR_SHA="${PHASE_DR_COMMIT%% *}"
  git show \
    --stat \
    --oneline \
    --decorate \
    --no-renames \
    "${PHASE_DR_SHA}"
fi

echo
echo "=== CANONICAL FIVE-CORRIDOR MAP ==="
echo "PHASE=AUTHORITATIVE_MISSION_PACKAGE_HANDOFF"
echo "CORRIDOR_1=OPERATIONAL_PACKAGE_AUTHORITY"
echo "CORRIDOR_2=PACKAGE_HANDOFF_CONTRACT"
echo "CORRIDOR_3=PROJECT_BOUND_HANDOFF"
echo "CORRIDOR_4=MISSION_CONTROL_INTAKE"
echo "CORRIDOR_5=HANDOFF_VALIDATION_AND_PHASE_CLOSURE"

echo
echo "=== CLASSIFICATION QUESTIONS ==="
echo "QUESTION_1=IS_PROJECT_BOUND_HANDOFF_FORMALLY_CLOSED"
echo "QUESTION_2=IS_MISSION_CONTROL_INTAKE_FORMALLY_CLOSED_OR_ONLY_IMPLEMENTATION_COMPLETE"
echo "QUESTION_3=IS_HANDOFF_VALIDATION_AND_PHASE_CLOSURE_FORMALLY_CLOSED"
echo "QUESTION_4=IS_AUTHORITATIVE_MISSION_PACKAGE_HANDOFF_PHASE_FORMALLY_CLOSED"
echo "QUESTION_5=IF_PHASE_IS_CLOSED_WHAT_SUCCESSOR_MILESTONE_OR_SCOPE_WAS_RECORDED_AT_CLOSURE"
echo "QUESTION_6=DOES_PACKAGE_SEMANTICS_WORK_REOPEN_ANY_CLOSED_HANDOFF_CORRIDOR_OR_PHASE"
echo "QUESTION_7=IF_NOT_SHOULD_CONTROL_RETURN_TO_THE_POST_HANDOFF_SUCCESSOR_MILESTONE_INSTEAD_OF_ANY_HANDOFF_CORRIDOR"

echo
echo "=== DECISION BOUNDARY ==="
echo "PROJECT_BOUND_HANDOFF_NEXT_OPEN_CORRIDOR_ASSUMPTION=WITHDRAWN_PENDING_RECONCILIATION"
echo "AUTHORITATIVE_MISSION_PACKAGE_HANDOFF_PHASE_CURRENT_STATUS=NOT_YET_FINALIZED_BY_THIS_SCRIPT"
echo "PACKAGE_SEMANTICS_REOPENS_HANDOFF_PHASE=NOT_ASSUMED"
echo "AUTOMATIC_CORRIDOR_ENTRY=NO"
echo "NEXT_ACTION=CLASSIFY_FORMAL_PHASE_CLOSURE_AND_RECORDED_SUCCESSOR_FROM_THIS_EVIDENCE"

git diff --check
git add classify-canonical-parent-phase-after-package-semantics.sh
git commit -m "Classify canonical parent phase after package semantics"
git push
