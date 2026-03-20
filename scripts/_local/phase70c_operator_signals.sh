#!/usr/bin/env bash
set -euo pipefail

LATEST_REPORT="$(ls -t docs/diagnostics_reports/DIAGNOSTICS_REPORT_*.md 2>/dev/null | head -n 1 || true)"

if [ -z "${LATEST_REPORT:-}" ]; then
  echo "NO_DIAGNOSTICS_REPORT"
  exit 1
fi

OVERALL="$(grep 'OVERALL=' "$LATEST_REPORT" | cut -d= -f2 || echo UNKNOWN)"
SYSTEM_STATE="$(grep 'SYSTEM_STATE=' "$LATEST_REPORT" | cut -d= -f2 || echo UNKNOWN)"

echo ""
echo "PHASE 70C OPERATOR SIGNALS"
echo "--------------------------"

if [ "$OVERALL" = "PASS" ]; then
  echo "HEALTH=PASS"
else
  echo "HEALTH=FAIL"
fi

if grep -q "LAYOUT CONTRACT" "$LATEST_REPORT"; then
  if grep -A3 "LAYOUT CONTRACT" "$LATEST_REPORT" | grep -q "PASS"; then
    echo "PROTECTION=OK"
  else
    echo "PROTECTION=DRIFT"
  fi
else
  echo "PROTECTION=UNKNOWN"
fi

if [ "$SYSTEM_STATE" = "HEALTHY" ]; then
  echo "RUNTIME=OK"
else
  echo "RUNTIME=DEGRADED"
fi

if grep -q "TELEMETRY DRIFT" "$LATEST_REPORT"; then
  if grep -A5 "TELEMETRY DRIFT" "$LATEST_REPORT" | grep -q "PASS"; then
    echo "TELEMETRY=OK"
  else
    echo "TELEMETRY=DRIFT"
  fi
else
  echo "TELEMETRY=UNKNOWN"
fi

if grep -q "REPLAY VALIDATION" "$LATEST_REPORT"; then
  if grep -A5 "REPLAY VALIDATION" "$LATEST_REPORT" | grep -q "PASS"; then
    echo "REPLAY=OK"
  else
    echo "REPLAY=UNVERIFIED"
  fi
else
  echo "REPLAY=UNKNOWN"
fi

echo ""
echo "SIGNALS_COMPLETE"

