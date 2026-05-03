#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

SOURCE_FILE="docs/visibility_normalized_latest.json"
OUTPUT_FILE="docs/dashboard_bridge_latest.json"

if [ ! -f "$SOURCE_FILE" ]; then
  echo "MISSING_SOURCE=${SOURCE_FILE}" >&2
  exit 1
fi

extract_json_value() {
  local key="$1"
  grep "\"${key}\"" "$SOURCE_FILE" | head -n 1 | cut -d '"' -f4
}

INTAKE_ID="$(extract_json_value intakeId)"
GOVERNANCE_DECISION="$(extract_json_value decision)"
APPROVAL_STATUS="$(grep '"status"' "$SOURCE_FILE" | sed -n '3p' | cut -d '"' -f4)"
EXECUTION_STATUS="$(grep '"status"' "$SOURCE_FILE" | sed -n '4p' | cut -d '"' -f4)"
FAILURE_STAGE="$(grep '"stage"' "$SOURCE_FILE" | head -n 1 | cut -d '"' -f4)"
FAILURE_ERROR="$(grep '"error"' "$SOURCE_FILE" | head -n 1 | cut -d '"' -f4)"

RUN_STATE="BLOCKED"
HEADLINE="Latest run blocked"
DETAIL="Execution did not complete."

if [ "$FAILURE_STAGE" = "entry_validation" ]; then
  RUN_STATE="FAILURE"
  HEADLINE="Latest run failed validation"
  DETAIL="$FAILURE_ERROR"
elif [ "$GOVERNANCE_DECISION" = "REJECTED" ]; then
  RUN_STATE="BLOCKED"
  HEADLINE="Latest run blocked by governance"
  DETAIL="$FAILURE_ERROR"
elif [ "$APPROVAL_STATUS" = "REJECTED" ]; then
  RUN_STATE="BLOCKED"
  HEADLINE="Latest run blocked by approval"
  DETAIL="$FAILURE_ERROR"
elif [ "$EXECUTION_STATUS" = "SUCCEEDED" ]; then
  RUN_STATE="SUCCESS"
  HEADLINE="Latest run succeeded"
  DETAIL="$EXECUTION_STATUS"
fi

cat > "$OUTPUT_FILE" <<JSON
{
  "runState": "${RUN_STATE}",
  "latestIntakeId": "${INTAKE_ID}",
  "latestGovernanceDecision": "${GOVERNANCE_DECISION}",
  "latestApprovalStatus": "${APPROVAL_STATUS}",
  "latestExecutionStatus": "${EXECUTION_STATUS}",
  "latestFailureStage": "${FAILURE_STAGE}",
  "latestFailureError": "${FAILURE_ERROR}",
  "uiSummary": {
    "headline": "${HEADLINE}",
    "detail": "${DETAIL}"
  }
}
JSON

echo "DASHBOARD_BRIDGE_OK"
echo "OUTPUT_FILE=${OUTPUT_FILE}"
