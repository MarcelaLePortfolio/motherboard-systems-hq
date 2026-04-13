#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

mkdir -p docs/proofs

if [ "$#" -ne 2 ]; then
  echo "USAGE: $0 \"<operator request>\" \"<APPROVE|REJECT>\"" >&2
  exit 1
fi

INPUT="$1"
APPROVAL_INPUT_RAW="$2"
APPROVAL_INPUT="$(printf '%s' "$APPROVAL_INPUT_RAW" | tr '[:lower:]' '[:upper:]')"
NORMALIZED_INPUT="$(printf '%s' "$INPUT" | xargs)"
INPUT_HASH="$(printf '%s' "$INPUT" | shasum -a 256 | awk '{print $1}')"

PLAN_ID="plan_${INPUT_HASH}"
APPROVAL_FILE="docs/proofs/approval_plan_${INPUT_HASH}.json"
APPROVAL_FAILURE_FILE="docs/proofs/approval_failure_plan_${INPUT_HASH}.json"
APPROVAL_INPUT_FAILURE_FILE="docs/proofs/approval_input_failure_plan_${INPUT_HASH}.json"
EXECUTION_FILE="docs/proofs/execution_plan_${INPUT_HASH}.json"

rm -f "$APPROVAL_FAILURE_FILE" "$APPROVAL_INPUT_FAILURE_FILE" "$EXECUTION_FILE"

if [ "$APPROVAL_INPUT" != "APPROVE" ] && [ "$APPROVAL_INPUT" != "REJECT" ]; then
  cat > "$APPROVAL_INPUT_FAILURE_FILE" <<JSON
{
  "planId":"${PLAN_ID}",
  "stage":"approval_input",
  "error":"INVALID_APPROVAL_DECISION"
}
JSON
  echo "ENTRYPOINT_FAILED"
  echo "INVALID_APPROVAL_DECISION"
  exit 0
fi

if [ "$APPROVAL_INPUT" = "REJECT" ]; then
  cat > "$APPROVAL_FILE" <<JSON
{
  "planId":"${PLAN_ID}",
  "operatorApproval":false,
  "approvalId":"approval_${INPUT_HASH}"
}
JSON

  cat > "$APPROVAL_FAILURE_FILE" <<JSON
{
  "planId":"${PLAN_ID}",
  "stage":"approval",
  "decision":"REJECTED",
  "reason":"OPERATOR_INPUT_REJECTED"
}
JSON

  echo "ENTRYPOINT_FAILED"
  echo "APPROVAL_REJECTED"
  exit 0
fi

cat > "$APPROVAL_FILE" <<JSON
{
  "planId":"${PLAN_ID}",
  "operatorApproval":true,
  "approvalId":"approval_${INPUT_HASH}"
}
JSON

OUTPUT="EXECUTION_OK: ${NORMALIZED_INPUT}"

cat > "$EXECUTION_FILE" <<JSON
{
  "planId":"${PLAN_ID}",
  "status":"SUCCEEDED",
  "output":"${OUTPUT}"
}
JSON

echo "ENTRYPOINT_OK"
echo "$OUTPUT"
