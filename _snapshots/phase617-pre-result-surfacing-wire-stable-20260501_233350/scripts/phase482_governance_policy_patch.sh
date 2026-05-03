#!/usr/bin/env bash

INPUT="$1"
NORMALIZED_INPUT="$(echo "$INPUT" | xargs)"

INPUT_HASH="$(printf '%s' "$INPUT" | shasum -a 256 | awk '{print $1}')"
PLAN_ID="plan_${INPUT_HASH}"

GOV_FILE="docs/proofs/governance_plan_${INPUT_HASH}.json"
FAIL_FILE="docs/proofs/governance_failure_plan_${INPUT_HASH}.json"

DECISION=""
REASON=""

# RULE 1 — EMPTY_INPUT
if [ -z "$NORMALIZED_INPUT" ]; then
  DECISION="REJECTED"
  REASON="EMPTY_INPUT"

# RULE 2 — UNSUPPORTED_REQUEST_CLASS
elif [[ "$NORMALIZED_INPUT" != echo\ * ]]; then
  DECISION="REJECTED"
  REASON="UNSUPPORTED_REQUEST_CLASS"

# RULE 3 — DISALLOWED_PATTERN
elif [[ "$NORMALIZED_INPUT" == *forbidden* ]]; then
  DECISION="REJECTED"
  REASON="DISALLOWED_PATTERN"

# RULE 4 — DEFAULT_ALLOW
else
  DECISION="APPROVED"
fi

cat > "$GOV_FILE" <<JSON
{"planId":"${PLAN_ID}","decision":"${DECISION}","decisionId":"decision_${INPUT_HASH}"}
JSON

if [ "$DECISION" = "REJECTED" ]; then
  cat > "$FAIL_FILE" <<JSON
{"planId":"${PLAN_ID}","stage":"governance","decision":"REJECTED","reason":"${REASON}"}
JSON

  echo "ENTRYPOINT_FAILED"
  echo "GOVERNANCE_REJECTED"
  exit 0
fi

echo "ENTRYPOINT_OK"
