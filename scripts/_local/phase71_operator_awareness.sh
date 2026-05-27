#!/usr/bin/env bash
set -euo pipefail

LATEST_REPORT="$(ls -t docs/diagnostics_reports/DIAGNOSTICS_REPORT_*.md 2>/dev/null | head -n 1 || true)"

if [ -z "${LATEST_REPORT:-}" ]; then
  echo "AWARENESS_STATUS=NO_REPORT"
  echo "ACTION=RUN_PHASE70B"
  exit 1
fi

OVERALL="$(grep 'OVERALL=' "$LATEST_REPORT" | cut -d= -f2 || echo UNKNOWN)"
FAIL_COUNT="$(grep 'FAIL_COUNT=' "$LATEST_REPORT" | cut -d= -f2 || echo 0)"

echo ""
echo "PHASE 71 OPERATOR AWARENESS"
echo "---------------------------"

if [ "$OVERALL" = "PASS" ]; then
  echo "SYSTEM_HEALTH=STABLE"
  echo "CRITICAL_FAILURES=0"
  echo "ACTION=NONE"
else
  echo "SYSTEM_HEALTH=ATTENTION_REQUIRED"
  echo "CRITICAL_FAILURES=$FAIL_COUNT"

  if grep -q "LAYOUT CONTRACT" "$LATEST_REPORT"; then
    if ! grep -A3 "LAYOUT CONTRACT" "$LATEST_REPORT" | grep -q "PASS"; then
      echo "ACTION=RESTORE_LAYOUT_GOLDEN"
      exit 0
    fi
  fi

  if grep -q "DOCKER" "$LATEST_REPORT"; then
    if ! grep -A5 "DOCKER" "$LATEST_REPORT" | grep -q "running"; then
      echo "ACTION=CHECK_DOCKER_RUNTIME"
      exit 0
    fi
  fi

  if grep -q "TELEMETRY DRIFT" "$LATEST_REPORT"; then
    if ! grep -A5 "TELEMETRY DRIFT" "$LATEST_REPORT" | grep -q "PASS"; then
      echo "ACTION=RUN_DRIFT_DETECTION"
      exit 0
    fi
  fi

  if grep -q "REPLAY VALIDATION" "$LATEST_REPORT"; then
    if ! grep -A5 "REPLAY VALIDATION" "$LATEST_REPORT" | grep -q "PASS"; then
      echo "ACTION=RUN_REPLAY_VALIDATION"
      exit 0
    fi
  fi

  echo "ACTION=REVIEW_DIAGNOSTICS"
fi

echo ""
echo "AWARENESS_COMPLETE"

