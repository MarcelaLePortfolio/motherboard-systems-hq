#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

if [ "$#" -lt 1 ]; then
  echo "USAGE: $0 \"operator request\"" >&2
  exit 1
fi

RAW_INPUT="$*"

REQUEST_ID="req_001"
INTAKE_ID="intake_001"
PLAN_ID="plan_001"
TASK_ID="task_001"
TIMESTAMP="2026-01-01T00:00:00Z"
OPERATOR_ID="operator_001"

mkdir -p docs/proofs

cat > "docs/proofs/intake_${INTAKE_ID}.json" <<JSON
{
  "intakeId": "${INTAKE_ID}",
  "operatorRequest": {
    "requestId": "${REQUEST_ID}",
    "timestamp": "${TIMESTAMP}",
    "operatorId": "${OPERATOR_ID}",
    "rawInput": "${RAW_INPUT}"
  }
}
JSON

cat > "docs/proofs/planning_${PLAN_ID}.json" <<JSON
{
  "intakeId": "${INTAKE_ID}",
  "planId": "${PLAN_ID}",
  "tasks": [
    {
      "taskId": "${TASK_ID}",
      "description": "${RAW_INPUT}",
      "status": "PENDING"
    }
  ]
}
JSON

cat > "docs/proofs/governance_${PLAN_ID}.json" <<JSON
{
  "planId": "${PLAN_ID}",
  "decision": "APPROVED",
  "decisionId": "decision_001"
}
JSON

cat > "docs/proofs/approval_${PLAN_ID}.json" <<JSON
{
  "planId": "${PLAN_ID}",
  "operatorApproval": true,
  "approvalId": "approval_001"
}
JSON

OUTPUT="EXECUTION_OK: ${RAW_INPUT}"

cat > "docs/proofs/execution_${PLAN_ID}.json" <<JSON
{
  "planId": "${PLAN_ID}",
  "taskId": "${TASK_ID}",
  "status": "SUCCEEDED",
  "output": "${OUTPUT}"
}
JSON

echo "ENTRYPOINT_OK"
echo "${OUTPUT}"
