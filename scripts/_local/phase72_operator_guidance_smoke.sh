#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

STATUS_OUTPUT="$(bash scripts/_local/operator_guidance.sh status)"
REPORT_OUTPUT="$(bash scripts/_local/operator_guidance.sh report)"

echo "PHASE 72 — OPERATOR GUIDANCE SMOKE"
echo "----------------------------------"

echo "$STATUS_OUTPUT" | grep -q '^PHASE 72 — OPERATOR GUIDANCE$'
echo "$STATUS_OUTPUT" | grep -q '^generated_at='
echo "$STATUS_OUTPUT" | grep -q '^dashboard_health_url='
echo "$STATUS_OUTPUT" | grep -q '^system_state='
echo "$STATUS_OUTPUT" | grep -q '^risk='
echo "$STATUS_OUTPUT" | grep -q '^recommended_next_action='
echo "$STATUS_OUTPUT" | grep -q '^safe_to_continue='

RISK_VALUE="$(echo "$STATUS_OUTPUT" | awk -F= '/^risk=/{print $2}')"
SAFE_VALUE="$(echo "$STATUS_OUTPUT" | awk -F= '/^safe_to_continue=/{print $2}')"
SYSTEM_STATE_VALUE="$(echo "$STATUS_OUTPUT" | awk -F= '/^system_state=/{print $2}')"

case "$RISK_VALUE" in
  LOW|MEDIUM|HIGH) ;;
  *)
    echo "Invalid risk value: $RISK_VALUE" >&2
    exit 1
    ;;
esac

case "$SAFE_VALUE" in
  YES|NO|INVESTIGATE) ;;
  *)
    echo "Invalid safe_to_continue value: $SAFE_VALUE" >&2
    exit 1
    ;;
esac

case "$SYSTEM_STATE_VALUE" in
  HEALTHY|DEGRADED) ;;
  *)
    echo "Invalid system_state value: $SYSTEM_STATE_VALUE" >&2
    exit 1
    ;;
esac

echo "$REPORT_OUTPUT" | grep -q '^report_path='
REPORT_PATH="$(echo "$REPORT_OUTPUT" | awk -F= '/^report_path=/{print $2}')"

test -n "$REPORT_PATH"
test -f "$REPORT_PATH"

grep -q '^PHASE 72 — OPERATOR GUIDANCE$' "$REPORT_PATH"
grep -q '^generated_at=' "$REPORT_PATH"
grep -q '^dashboard_health_url=' "$REPORT_PATH"
grep -q '^system_state=' "$REPORT_PATH"
grep -q '^risk=' "$REPORT_PATH"
grep -q '^recommended_next_action=' "$REPORT_PATH"
grep -q '^safe_to_continue=' "$REPORT_PATH"
grep -q '^dashboard_container=' "$REPORT_PATH"
grep -q '^protection_gate=' "$REPORT_PATH"
grep -q '^api_health=' "$REPORT_PATH"
grep -q '^git_commit=' "$REPORT_PATH"

echo "PASS: operator guidance contract verified"
