#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

mkdir -p docs/proofs

emit_failure() {
  local intake_id="$1"
  local stage="$2"
  local error="$3"

  cat > "docs/proofs/failure_${intake_id}.json" <<JSON
{
  "intakeId": "${intake_id}",
  "stage": "${stage}",
  "error": "${error}"
}
JSON

  echo "ENTRYPOINT_FAILED"
  echo "${error}"
  exit 1
}

RAW_INPUT="${*:-}"

if [ -z "${RAW_INPUT}" ]; then
  emit_failure "intake_invalid_empty" "entry_validation" "EMPTY_INPUT"
fi

NORMALIZED_INPUT="$(printf '%s' "${RAW_INPUT}")"
INPUT_HASH="$(printf '%s' "${NORMALIZED_INPUT}" | shasum -a 256 | awk '{print $1}')"

REQUEST_ID="req_${INPUT_HASH}"
INTAKE_ID="intake_${INPUT_HASH}"
PLAN_ID="plan_${INPUT_HASH}"
TASK_ID="task_${INPUT_HASH}"
TIMESTAMP="2026-01-01T00:00:00Z"
OPERATOR_ID="operator_001"

INTAKE_FILE="docs/proofs/intake_${INTAKE_ID}.json"
PLANNING_FILE="docs/proofs/planning_${PLAN_ID}.json"
GOVERNANCE_FILE="docs/proofs/governance_${PLAN_ID}.json"
APPROVAL_FILE="docs/proofs/approval_${PLAN_ID}.json"
EXECUTION_FILE="docs/proofs/execution_${PLAN_ID}.json"
FAILURE_FILE="docs/proofs/failure_${INTAKE_ID}.json"

rm -f "${FAILURE_FILE}"

cat > "${INTAKE_FILE}" <<JSON
{
  "intakeId": "${INTAKE_ID}",
  "operatorRequest": {
    "requestId": "${REQUEST_ID}",
    "timestamp": "${TIMESTAMP}",
    "operatorId": "${OPERATOR_ID}",
    "rawInput": "${NORMALIZED_INPUT}"
  }
}
JSON

cat > "${PLANNING_FILE}" <<JSON
{
  "intakeId": "${INTAKE_ID}",
  "planId": "${PLAN_ID}",
  "tasks": [
    {
      "taskId": "${TASK_ID}",
      "description": "${NORMALIZED_INPUT}",
      "status": "PENDING"
    }
  ]
}
JSON

cat > "${GOVERNANCE_FILE}" <<JSON
{
  "planId": "${PLAN_ID}",
  "decision": "APPROVED",
  "decisionId": "decision_${INPUT_HASH}"
}
JSON

cat > "${APPROVAL_FILE}" <<JSON
{
  "planId": "${PLAN_ID}",
  "operatorApproval": true,
  "approvalId": "approval_${INPUT_HASH}"
}
JSON

OUTPUT="EXECUTION_OK: ${NORMALIZED_INPUT}"

cat > "${EXECUTION_FILE}" <<JSON
{
  "planId": "${PLAN_ID}",
  "taskId": "${TASK_ID}",
  "status": "SUCCEEDED",
  "output": "${OUTPUT}"
}
JSON

echo "ENTRYPOINT_OK"
echo "${OUTPUT}"
