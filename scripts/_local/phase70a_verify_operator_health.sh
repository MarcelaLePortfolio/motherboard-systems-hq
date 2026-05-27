#!/usr/bin/env bash
set -euo pipefail

TMP_OUTPUT="$(mktemp)"
trap 'rm -f "$TMP_OUTPUT"' EXIT

echo ""
echo "PHASE 70A VERIFY OPERATOR HEALTH"
echo "--------------------------------"

if bash scripts/_local/phase70a_operator_health.sh | tee "$TMP_OUTPUT"; then
  SNAPSHOT_PATH="$(awk '/^docs\/health_snapshots\/HEALTH_SNAPSHOT_/ { path=$0 } END { print path }' "$TMP_OUTPUT")"

  echo ""
  echo "VERIFY_RESULT=PASS"
  if [ -n "${SNAPSHOT_PATH:-}" ]; then
    echo "LATEST_SNAPSHOT=$SNAPSHOT_PATH"
  else
    echo "LATEST_SNAPSHOT=UNKNOWN"
  fi
  exit 0
else
  SNAPSHOT_PATH="$(awk '/^docs\/health_snapshots\/HEALTH_SNAPSHOT_/ { path=$0 } END { print path }' "$TMP_OUTPUT")"

  echo ""
  echo "VERIFY_RESULT=FAIL"
  if [ -n "${SNAPSHOT_PATH:-}" ]; then
    echo "LATEST_SNAPSHOT=$SNAPSHOT_PATH"
  else
    echo "LATEST_SNAPSHOT=UNKNOWN"
  fi
  exit 1
fi
