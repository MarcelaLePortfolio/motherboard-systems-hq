#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_runtime_results_summary.txt"

mkdir -p docs

RESPONSE=$(curl -s http://localhost:3000/api/diagnostics/system-health || echo "REQUEST_FAILED")

COUNT=$(echo "$RESPONSE" | rg -o 'SYSTEM_HEALTH' | wc -l | tr -d ' ')

STATUS="UNKNOWN"

if [ "$RESPONSE" = "REQUEST_FAILED" ]; then
  STATUS="ENDPOINT_FAILED"
elif [ "$COUNT" -eq 1 ]; then
  STATUS="FIX_CONFIRMED"
elif [ "$COUNT" -gt 1 ]; then
  STATUS="UPSTREAM_DUPLICATION"
elif [ "$COUNT" -eq 0 ]; then
  STATUS="SIGNAL_MISSING"
fi

cat > "$OUT" <<EOT
PHASE 464.X RESULT SUMMARY
==========================

STATUS: $STATUS
SYSTEM_HEALTH COUNT: $COUNT

INTERPRETATION:
- FIX_CONFIRMED → duplication resolved
- UPSTREAM_DUPLICATION → issue exists before route
- SIGNAL_MISSING → route broken or renamed
- ENDPOINT_FAILED → server or route failure

RAW RESPONSE:
$RESPONSE
EOT

# HARD GUARANTEE FILE EXISTS BEFORE GIT
if [ ! -f "$OUT" ]; then
  echo "ERROR: output file was not created"
  exit 1
fi

echo "Wrote $OUT"
echo "STATUS: $STATUS"

