#!/usr/bin/env bash

set -euo pipefail

RAW_INPUT="${1:-}"

# --- NORMALIZATION ---
NORMALIZED_INPUT="$(printf "%s" "$RAW_INPUT" | tr -d '\r')"

# --- HASHES ---
INPUT_HASH="$(printf '%s' "$NORMALIZED_INPUT" | shasum -a 256 | awk '{print $1}')"

INTAKE_ID="intake_${INPUT_HASH}"
PLAN_ID="plan_${INPUT_HASH}"
TASK_ID="task_${INPUT_HASH}"

INTAKE_FILE="docs/proofs/intake_${INTAKE_ID}.json"
PLANNING_FILE="docs/proofs/planning_${PLAN_ID}.json"
GOVERNANCE_FILE="docs/proofs/governance_${PLAN_ID}.json"
GOVERNANCE_FAILURE_FILE="docs/proofs/governance_failure_${PLAN_ID}.json"
APPROVAL_FILE="docs/proofs/approval_${PLAN_ID}.json"
EXECUTION_FILE="docs/proofs/execution_${PLAN_ID}.json"

# --- VALIDATION (reuse existing rules) ---
if [[ -z "$RAW_INPUT" ]]; then
  cat > "docs/proofs/failure_intake_invalid_empty.json" <<JSON
{"intakeId":"invalid_empty","stage":"entry_validation","error":"EMPTY_INPUT"}
JSON
  echo "ENTRYPOINT_FAILED"
  echo "EMPTY_INPUT"
  exit 0
fi

if [[ "$RAW_INPUT" =~ ^[[:space:]]+$ ]]; then
  cat > "docs/proofs/failure_intake_invalid_whitespace.json" <<JSON
{"intakeId":"invalid_whitespace","stage":"entry_validation","error":"EMPTY_INPUT_NORMALIZED"}
JSON
  echo "ENTRYPOINT_FAILED"
  echo "EMPTY_INPUT_NORMALIZED"
  exit 0
fi

if [[ ${#RAW_INPUT} -gt 1024 ]]; then
  cat > "docs/proofs/failure_intake_${INPUT_HASH}.json" <<JSON
{"intakeId":"${INTAKE_ID}","stage":"entry_validation","error":"INPUT_TOO_LONG"}
JSON
  echo "ENTRYPOINT_FAILED"
  echo "INPUT_TOO_LONG"
  exit 0
fi

if printf '%s' "$RAW_INPUT" | grep -q '[^[:print:][:space:]]'; then
  cat > "docs/proofs/failure_intake_${INPUT_HASH}.json" <<JSON
{"intakeId":"${INTAKE_ID}","stage":"entry_validation","error":"INVALID_CHARACTERS"}
JSON
  echo "ENTRYPOINT_FAILED"
  echo "INVALID_CHARACTERS"
  exit 0
fi

# --- INTAKE ---
cat > "$INTAKE_FILE" <<JSON
{"intakeId":"${INTAKE_ID}","input":"${NORMALIZED_INPUT}"}
JSON

# --- CLASSIFICATION ---
if [[ "$NORMALIZED_INPUT" == echo\ * ]]; then
  REQUEST_CLASS="SIMPLE_ECHO"
else
  REQUEST_CLASS="UNSUPPORTED_VALID_PATTERN"
fi

# --- PLANNING ---
cat > "$PLANNING_FILE" <<JSON
{
  "intakeId":"${INTAKE_ID}",
  "planId":"${PLAN_ID}",
  "tasks":[{"taskId":"${TASK_ID}","description":"${NORMALIZED_INPUT}","status":"PENDING"}]
}
JSON

# --- GOVERNANCE DECISION ---
if [[ "$REQUEST_CLASS" == "SIMPLE_ECHO" ]]; then
  DECISION="APPROVED"

  cat > "$GOVERNANCE_FILE" <<JSON
{"planId":"${PLAN_ID}","decision":"APPROVED","decisionId":"decision_${INPUT_HASH}"}
JSON

else
  DECISION="REJECTED"

  cat > "$GOVERNANCE_FILE" <<JSON
{"planId":"${PLAN_ID}","decision":"REJECTED","decisionId":"decision_${INPUT_HASH}"}
JSON

  cat > "$GOVERNANCE_FAILURE_FILE" <<JSON
{"planId":"${PLAN_ID}","stage":"governance","decision":"REJECTED","reason":"UNSUPPORTED_REQUEST_CLASS"}
JSON

  echo "ENTRYPOINT_FAILED"
  echo "GOVERNANCE_REJECTED"
  exit 0
fi

# --- APPROVAL (still simulated) ---
cat > "$APPROVAL_FILE" <<JSON
{"planId":"${PLAN_ID}","operatorApproval":true,"approvalId":"approval_${INPUT_HASH}"}
JSON

# --- EXECUTION ---
OUTPUT="EXECUTION_OK: ${NORMALIZED_INPUT}"

cat > "$EXECUTION_FILE" <<JSON
{"planId":"${PLAN_ID}","taskId":"${TASK_ID}","status":"SUCCEEDED","output":"${OUTPUT}"}
JSON

echo "ENTRYPOINT_OK"
echo "$OUTPUT"
