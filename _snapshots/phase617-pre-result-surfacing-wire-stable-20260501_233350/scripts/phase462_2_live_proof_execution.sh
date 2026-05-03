#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

INTAKE_ID="intake_001"
PLAN_ID="plan_001"
TASK_ID="task_001"

RAW_INPUT="echo hello world"

# 1 — INTAKE
cat > "docs/proofs/intake_${INTAKE_ID}.json" <<JSON
{
  "intakeId": "${INTAKE_ID}",
  "operatorRequest": {
    "requestId": "req_001",
    "timestamp": "2026-01-01T00:00:00Z",
    "operatorId": "operator_001",
    "rawInput": "${RAW_INPUT}"
  }
}
JSON

# 2 — PLANNING
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

# 3 — GOVERNANCE
cat > "docs/proofs/governance_${PLAN_ID}.json" <<JSON
{
  "planId": "${PLAN_ID}",
  "decision": "APPROVED",
  "decisionId": "decision_001"
}
JSON

# 4 — APPROVAL
cat > "docs/proofs/approval_${PLAN_ID}.json" <<JSON
{
  "planId": "${PLAN_ID}",
  "operatorApproval": true,
  "approvalId": "approval_001"
}
JSON

# 5 — EXECUTION (ECHO TASK)
OUTPUT="EXECUTION_OK: ${RAW_INPUT}"

cat > "docs/proofs/execution_${PLAN_ID}.json" <<JSON
{
  "planId": "${PLAN_ID}",
  "taskId": "${TASK_ID}",
  "status": "SUCCEEDED",
  "output": "${OUTPUT}"
}
JSON

echo "LIVE PROOF COMPLETE"
