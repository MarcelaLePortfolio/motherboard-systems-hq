#!/usr/bin/env bash

set -e

OUTPUT_FILE="docs/visibility_normalized_latest.json"

LATEST_INTAKE=$(ls -t docs/proofs/intake_intake_*.json 2>/dev/null | head -n1 || true)
LATEST_GOV=$(ls -t docs/proofs/governance_plan_*.json 2>/dev/null | head -n1 || true)
LATEST_GOV_FAIL=$(ls -t docs/proofs/governance_failure_plan_*.json 2>/dev/null | head -n1 || true)
LATEST_APPROVAL=$(ls -t docs/proofs/approval_plan_*.json 2>/dev/null | head -n1 || true)
LATEST_APPROVAL_FAIL=$(ls -t docs/proofs/approval_failure_plan_*.json 2>/dev/null | head -n1 || true)
LATEST_EXEC=$(ls -t docs/proofs/execution_plan_*.json 2>/dev/null | head -n1 || true)
LATEST_FAIL=$(ls -t docs/proofs/failure_intake_*.json 2>/dev/null | head -n1 || true)

INTAKE_ID=""
GOV_DECISION=""
GOV_ID=""
APPROVAL_STATUS="SKIPPED"
APPROVAL_ID=""
EXEC_STATUS="BLOCKED"
EXEC_OUTPUT=""
FAIL_STAGE="none"
FAIL_ERROR=""

if [ -f "$LATEST_INTAKE" ]; then
  INTAKE_ID=$(cat "$LATEST_INTAKE" | grep intakeId | cut -d '"' -f4)
fi

if [ -f "$LATEST_GOV" ]; then
  GOV_DECISION=$(cat "$LATEST_GOV" | grep decision | head -n1 | cut -d '"' -f4)
  GOV_ID=$(cat "$LATEST_GOV" | grep decisionId | cut -d '"' -f4)
fi

if [ -f "$LATEST_GOV_FAIL" ]; then
  FAIL_STAGE="governance"
  FAIL_ERROR="REJECTED"
fi

if [ -f "$LATEST_APPROVAL" ]; then
  if grep -q '"operatorApproval": false' "$LATEST_APPROVAL"; then
    APPROVAL_STATUS="REJECTED"
  else
    APPROVAL_STATUS="APPROVED"
  fi
  APPROVAL_ID=$(cat "$LATEST_APPROVAL" | grep approvalId | cut -d '"' -f4)
fi

if [ -f "$LATEST_APPROVAL_FAIL" ]; then
  FAIL_STAGE="approval"
  FAIL_ERROR="REJECTED"
fi

if [ -f "$LATEST_EXEC" ]; then
  EXEC_STATUS="SUCCEEDED"
  EXEC_OUTPUT=$(cat "$LATEST_EXEC" | grep output | cut -d '"' -f4)
fi

if [ -f "$LATEST_FAIL" ]; then
  FAIL_STAGE="entry_validation"
  FAIL_ERROR=$(cat "$LATEST_FAIL" | grep error | cut -d '"' -f4)
fi

cat > "$OUTPUT_FILE" <<JSON
{
  "intake": {
    "intakeId": "${INTAKE_ID}",
    "status": "$( [ -f "$LATEST_FAIL" ] && echo FAILURE || echo SUCCESS )"
  },
  "governance": {
    "decision": "${GOV_DECISION}",
    "decisionId": "${GOV_ID}"
  },
  "approval": {
    "status": "${APPROVAL_STATUS}",
    "approvalId": "${APPROVAL_ID}"
  },
  "execution": {
    "status": "${EXEC_STATUS}",
    "output": "${EXEC_OUTPUT}"
  },
  "failure": {
    "stage": "${FAIL_STAGE}",
    "error": "${FAIL_ERROR}"
  }
}
JSON

echo "VISIBILITY_NORMALIZED_OK"
echo "OUTPUT_FILE=${OUTPUT_FILE}"
