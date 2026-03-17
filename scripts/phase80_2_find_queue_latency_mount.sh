#!/usr/bin/env bash
set -euo pipefail

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
OUT="PHASE80_2_QUEUE_LATENCY_MOUNT_DISCOVERY_${STAMP}.md"

{
  echo "# Phase 80.2 — Queue Latency Mount Discovery"
  echo
  echo "- Generated at: ${STAMP}"
  echo
  echo "## Candidate files"
  echo
  find dashboard -type f \( -name "*.tsx" -o -name "*.ts" -o -name "*.jsx" -o -name "*.js" \) \
    | grep -E "page|layout|dashboard|telemetry|metrics|overview|tasks|ops|home|index" \
    | sort
  echo
  echo "## Files referencing telemetry/task concepts"
  echo
  grep -RInE "Tasks Running|Tasks Completed|Tasks Failed|Success Rate|telemetry|metrics|task(s)?\\b|ops\\b|operator|dashboard" dashboard \
    --include="*.tsx" --include="*.ts" --include="*.jsx" --include="*.js" || true
  echo
  echo "## Files already importing from components barrel"
  echo
  grep -RInE "from ['\"][.]{1,2}/components['\"]|from ['\"][.]{1,2}/components/index['\"]" dashboard \
    --include="*.tsx" --include="*.ts" --include="*.jsx" --include="*.js" || true
  echo
  echo "## Files already rendering cards/panels"
  echo
  grep -RInE "Card|Panel|Summary|Overview|Metric|Stat|Telemetry" dashboard/src \
    --include="*.tsx" --include="*.ts" --include="*.jsx" --include="*.js" || true
} > "${OUT}"

echo "Wrote ${OUT}"
