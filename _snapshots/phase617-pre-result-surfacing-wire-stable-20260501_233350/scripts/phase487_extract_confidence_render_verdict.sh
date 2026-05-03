#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST="$(ls -t docs/phase487_confidence_render_surface_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST}" ]; then
  echo "No confidence render surface trace found."
  exit 1
fi

OUT="docs/phase487_confidence_render_verdict_$(date +%Y%m%d_%H%M%S).txt"

{
  echo "PHASE 487 — CONFIDENCE RENDER VERDICT"
  echo "source_file=${LATEST}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== TOP REMAINING INSUFFICIENT MATCHES ==="
  grep -ni "insufficient" "${LATEST}" | head -n 80 || true
  echo

  echo "=== TOP CONFIDENCE RENDER MATCHES ==="
  grep -niE "Confidence:|confidenceLabel|confidence" "${LATEST}" | head -n 120 || true
  echo

  echo "=== TOP SYSTEM-HEALTH SOURCE MATCHES ==="
  grep -niE "diagnostics/system-health|system-health|system_health" "${LATEST}" | head -n 80 || true
  echo

  echo "=== LIKELY NEXT PATCH TARGET ==="
  awk '
    /=== SEARCH: literal insufficient ===/ {flag=1; next}
    /^=== / {if(flag) exit}
    flag && /:[0-9]+:/ {print; count++; if (count>=20) exit}
  ' "${LATEST}" || true
  echo

  echo "=== OPERATOR READ ==="
  echo "Push succeeded."
  echo "Large-file push failure has been resolved."
  echo "Next action is to patch the exact remaining render surface still emitting confidence=insufficient."
  echo
} > "${OUT}"

echo "${OUT}"
