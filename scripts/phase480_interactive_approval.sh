#!/usr/bin/env bash

INPUT="$1"
APPROVAL_INPUT="$2"

NORMALIZED_INPUT="$(echo "$INPUT" | xargs)"

INPUT_HASH="$(printf '%s' "$INPUT" | shasum -a 256 | awk '{print $1}')"

PLAN_ID="plan_${INPUT_HASH}"
APPROVAL_FILE="docs/proofs/approval_plan_${INPUT_HASH}.json"
APPROVAL_FAILURE_FILE="docs/proofs/approval_failure_plan_${INPUT_HASH}.json"
EXECUTION_FILE="docs/proofs/execution_plan_${INPUT_HASH}.json"

# --- APPROVAL DECISION ---
if [ "$APPROVAL_INPUT" = "REJECT" ]; then

  cat > "$APPROVAL_FILE" <<JSON
{"planId":"${PLAN_ID}","operatorApproval":false,"approvalId":"approval_${INPUT_HASH}"}
JSON

  cat > "$APPROVAL_FAILURE_FILE" <<JSON
{"planId":"${PLAN_ID}","stage":"approval","decision":"REJECTED","reason":"OPERATOR_INPUT_REJECTED"}
JSON

  echo "ENTRYPOINT_FAILED"
  echo "APPROVAL_REJECTED"
  exit 0

fi

# --- APPROVE PATH ---
cat > "$APPROVAL_FILE" <<JSON
{"planId":"${PLAN_ID}","operatorApproval":true,"approvalId":"approval_${INPUT_HASH}"}
JSON

OUTPUT="EXECUTION_OK: ${NORMALIZED_INPUT}"

cat > "$EXECUTION_FILE" <<JSON
{"planId":"${PLAN_ID}","status":"SUCCEEDED","output":"${OUTPUT}"}
JSON

echo "ENTRYPOINT_OK"
echo "$OUTPUT"

