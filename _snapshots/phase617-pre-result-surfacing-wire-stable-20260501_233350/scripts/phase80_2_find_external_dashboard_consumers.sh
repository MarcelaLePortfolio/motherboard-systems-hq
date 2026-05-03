#!/usr/bin/env bash
set -euo pipefail

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
OUT="PHASE80_2_EXTERNAL_DASHBOARD_CONSUMER_DISCOVERY_${STAMP}.md"

{
  echo "# Phase 80.2 — External Dashboard Consumer Discovery"
  echo
  echo "Generated: ${STAMP}"
  echo

  echo "## Possible app entrypoints outside dashboard/"
  echo
  find . \
    -path "./.git" -prune -o \
    -path "./node_modules" -prune -o \
    -path "./dashboard" -prune -o \
    -type f \
    \( -name "App.tsx" -o -name "App.ts" -o -name "index.tsx" -o -name "index.ts" -o -name "page.tsx" -o -name "page.ts" -o -name "layout.tsx" -o -name "layout.ts" \) \
    -print | sort
  echo

  echo "## Imports or references to dashboard/src/components"
  echo
  grep -RInE "dashboard/src/components|from ['\"][^'\"]*dashboard/src/components|from ['\"][^'\"]*components['\"]" . \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --exclude-dir=dashboard \
    --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null || true
  echo

  echo "## Imports or references to dashboard/src/telemetry"
  echo
  grep -RInE "dashboard/src/telemetry|from ['\"][^'\"]*dashboard/src/telemetry|from ['\"][^'\"]*telemetry['\"]" . \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --exclude-dir=dashboard \
    --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null || true
  echo

  echo "## Direct references to QueueLatencyCard or computeQueueLatency"
  echo
  grep -RInE "QueueLatencyCard|computeQueueLatency" . \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null || true
  echo

  echo "## Existing telemetry/task dashboard candidates outside dashboard/"
  echo
  grep -RInE "Tasks Running|Tasks Completed|Tasks Failed|Success Rate|telemetry|operator|runbook|metrics|dashboard" . \
    --exclude-dir=.git \
    --exclude-dir=node_modules \
    --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null || true
  echo
} > "${OUT}"

echo "Wrote ${OUT}"
