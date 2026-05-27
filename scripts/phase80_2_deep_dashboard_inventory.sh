#!/usr/bin/env bash
set -euo pipefail

STAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
OUT="PHASE80_2_DEEP_DASHBOARD_INVENTORY_${STAMP}.md"

{
  echo "# Phase 80.2 — Deep Dashboard Inventory"
  echo
  echo "Generated: ${STAMP}"
  echo

  echo "## Root package manifests"
  echo
  find . -maxdepth 3 \( -name "package.json" -o -name "tsconfig.json" -o -name "vite.config.*" -o -name "next.config.*" \) | sort
  echo

  echo "## Dashboard tree"
  echo
  find dashboard -maxdepth 6 -print | sort
  echo

  echo "## Source-like files under dashboard"
  echo
  find dashboard -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.json" -o -name "*.md" \) | sort
  echo

  echo "## Imports that suggest app entry wiring"
  echo
  grep -RInE "ReactDOM|createRoot|App|render\\(|next/|use client|BrowserRouter|Routes|Route" dashboard . \
    --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null || true
  echo

  echo "## Queue latency component references"
  echo
  grep -RInE "QueueLatencyCard|computeQueueLatency" . \
    --include="*.ts" --include="*.tsx" --include="*.js" --include="*.jsx" 2>/dev/null || true
  echo
} > "${OUT}"

echo "Wrote ${OUT}"
