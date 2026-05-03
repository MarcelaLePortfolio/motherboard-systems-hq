#!/usr/bin/env bash
set -euo pipefail

OUT="docs/phase464_x_runtime_verification.txt"

{
  echo "PHASE 464.X — RUNTIME VERIFICATION"
  echo "=================================="
  echo
  echo "Timestamp (UTC): $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
  echo

  echo "STEP 1 — Hit system health endpoint"
  echo "-----------------------------------"
  curl -s http://localhost:3000/api/diagnostics/system-health || echo "Request failed"
  echo
  echo

  echo "STEP 2 — Check for repetition pattern"
  echo "-------------------------------------"
  curl -s http://localhost:3000/api/diagnostics/system-health | rg 'SYSTEM_HEALTH' -n || true
  echo

  echo "STEP 3 — Count occurrences"
  echo "--------------------------"
  COUNT=$(curl -s http://localhost:3000/api/diagnostics/system-health | rg -o 'SYSTEM_HEALTH' | wc -l | tr -d ' ')
  echo "SYSTEM_HEALTH occurrences: $COUNT"
  echo

  echo "STEP 4 — Expected result"
  echo "------------------------"
  echo "• Expected: 1 occurrence"
  echo "• If >1: duplication still upstream"
  echo "• If 0: patch broke signal"
  echo

  echo "STEP 5 — Container health check"
  echo "-------------------------------"
  docker compose ps || true
  echo

  echo "DECISION"
  echo "--------"
  echo "If SYSTEM_HEALTH == 1 → FIX CONFIRMED"
  echo "If SYSTEM_HEALTH > 1 → ROOT CAUSE IS UPSTREAM (aggregation layer)"
  echo "If endpoint fails → ROUTE INTEGRATION ISSUE"
} > "$OUT"

echo "Wrote $OUT"

