#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_guidance_patch_verification_${STAMP}.txt"

{
  echo "PHASE 487 — GUIDANCE PATCH VERIFICATION"
  echo "timestamp=${STAMP}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== TARGET SOURCE CHECK ==="
  rg -n -C 3 "Signal quality is limited; interpret with caution|Signal quality currently unavailable; awaiting stronger signal|Signal quality is insufficient for strong interpretation" src/cognition/operatorGuidanceMapping.ts || true
  echo

  echo "=== TYPECHECK ==="
  if command -v pnpm >/dev/null 2>&1; then
    pnpm exec tsc --noEmit 2>&1 || true
  else
    echo "pnpm not found; skipping typecheck"
  fi
  echo

  echo "=== DASHBOARD HTTP CHECK ==="
  curl -I --max-time 5 http://localhost:3000 2>&1 || echo "localhost:3000 unreachable"
  curl -I --max-time 5 http://localhost:8080 2>&1 || echo "localhost:8080 unreachable"
  echo

  echo "=== FINAL READ ==="
  echo "PASS if:"
  echo "1. old insufficient string no longer appears in source"
  echo "2. new guarded messages appear in source"
  echo "3. no new typecheck regressions introduced"
  echo "4. dashboard remains reachable"
  echo
} > "${OUT}"

echo "${OUT}"
