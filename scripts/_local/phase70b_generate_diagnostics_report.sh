#!/usr/bin/env bash
set -euo pipefail

LATEST_SNAPSHOT="$(ls -t docs/health_snapshots/HEALTH_SNAPSHOT_*.md 2>/dev/null | head -n 1 || true)"

if [ -z "${LATEST_SNAPSHOT:-}" ]; then
  echo "NO_SNAPSHOT_FOUND"
  exit 1
fi

OUTDIR="docs/diagnostics_reports"
STAMP="$(date -u +"%Y%m%d_%H%M%S")"
OUTFILE="$OUTDIR/DIAGNOSTICS_REPORT_$STAMP.md"

mkdir -p "$OUTDIR"

PASS_COUNT="$(grep 'PASS_COUNT=' "$LATEST_SNAPSHOT" | cut -d= -f2 || echo 0)"
FAIL_COUNT="$(grep 'FAIL_COUNT=' "$LATEST_SNAPSHOT" | cut -d= -f2 || echo 0)"
OVERALL="$(grep 'OVERALL=' "$LATEST_SNAPSHOT" | cut -d= -f2 || echo UNKNOWN)"

{
echo "PHASE 70B DIAGNOSTICS REPORT"
echo "Timestamp: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
echo "Source Snapshot: $LATEST_SNAPSHOT"
echo "--------------------------------------------------"

echo ""
echo "SUMMARY"
echo "PASS_COUNT=$PASS_COUNT"
echo "FAIL_COUNT=$FAIL_COUNT"
echo "OVERALL=$OVERALL"

echo ""
echo "CLASSIFICATION"

if [ "$FAIL_COUNT" -eq 0 ]; then
  echo "SYSTEM_STATE=HEALTHY"
else
  echo "SYSTEM_STATE=DEGRADED"
fi

echo ""
echo "PROTECTION STATUS"

grep -A3 "LAYOUT CONTRACT" "$LATEST_SNAPSHOT" || true

echo ""
echo "RUNTIME STATUS"

grep -A10 "DOCKER" "$LATEST_SNAPSHOT" || true

echo ""
echo "TELEMETRY STATUS"

grep -A10 "TELEMETRY DRIFT" "$LATEST_SNAPSHOT" || true

echo ""
echo "REPLAY STATUS"

grep -A10 "REPLAY VALIDATION" "$LATEST_SNAPSHOT" || true

echo ""
echo "FAILURE SURFACES"

if [ "$FAIL_COUNT" -eq 0 ]; then
  echo "NONE"
else
  grep -n "FAIL" "$LATEST_SNAPSHOT" || true
fi

echo ""
echo "REPORT COMPLETE"

} > "$OUTFILE"

echo "Diagnostics report written to:"
echo "$OUTFILE"

