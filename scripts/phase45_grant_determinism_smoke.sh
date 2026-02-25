#!/usr/bin/env bash
set -euo pipefail

BASE="http://127.0.0.1:8080"

echo "=== Phase 45: Grant Determinism Smoke ==="

echo
echo "1) Seed baseline task (Tier B, should deny without grant)"
TASK_ID="phase45.grant.determinism.$RANDOM"

curl -fsS -X POST "$BASE/api/tasks" \
  -H "Content-Type: application/json" \
  -d "{
    \"task_id\": \"$TASK_ID\",
    \"action\": \"test.restricted.action\",
    \"tier\": \"B\"
  }" > /dev/null

echo "2) Evaluate policy (expect deny)"
DENY_RESULT="$(curl -fsS "$BASE/api/policy/evaluate?task_id=$TASK_ID" | jq -r '.decision')"

if [[ "$DENY_RESULT" != "deny" ]]; then
  echo "FAIL: expected deny before grant, got $DENY_RESULT"
  exit 1
fi

echo "3) Insert grant"
curl -fsS -X POST "$BASE/api/policy/grants" \
  -H "Content-Type: application/json" \
  -d "{
    \"action\": \"test.restricted.action\",
    \"tier\": \"B\",
    \"reason\": \"phase45 determinism test\"
  }" > /dev/null

echo "4) Evaluate policy (expect allow)"
ALLOW_RESULT="$(curl -fsS "$BASE/api/policy/evaluate?task_id=$TASK_ID" | jq -r '.decision')"

if [[ "$ALLOW_RESULT" != "allow" ]]; then
  echo "FAIL: expected allow after grant, got $ALLOW_RESULT"
  exit 1
fi

echo "5) Re-evaluate multiple times to confirm determinism"
for i in {1..5}; do
  LOOP_RESULT="$(curl -fsS "$BASE/api/policy/evaluate?task_id=$TASK_ID" | jq -r '.decision')"
  if [[ "$LOOP_RESULT" != "allow" ]]; then
    echo "FAIL: nondeterministic decision on iteration $i"
    exit 1
  fi
done

echo
echo "OK: Grant flip deterministic and stable."
