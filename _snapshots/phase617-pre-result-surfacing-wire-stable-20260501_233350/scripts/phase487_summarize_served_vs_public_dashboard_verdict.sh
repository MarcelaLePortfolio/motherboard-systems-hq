#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST_COMPARE="$(ls -t docs/phase487_compare_served_dashboard_vs_public_html_*.txt 2>/dev/null | head -n 1 || true)"
LATEST_SERVED="$(ls -t docs/phase487_served_dashboard_snapshot_*.html 2>/dev/null | head -n 1 || true)"

if [ -z "${LATEST_COMPARE}" ] || [ -z "${LATEST_SERVED}" ]; then
  echo "Required Phase 487 compare artifacts not found."
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_served_vs_public_dashboard_verdict_${STAMP}.txt"

{
  echo "PHASE 487 — SERVED VS PUBLIC DASHBOARD VERDICT"
  echo "timestamp=${STAMP}"
  echo "compare_file=${LATEST_COMPARE}"
  echo "served_snapshot=${LATEST_SERVED}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== SERVED BODY STRING CHECK ==="
  awk '/=== SERVED BODY STRING CHECK ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST_COMPARE}" | sed '/^[[:space:]]*$/d' || true
  echo

  echo "=== LOCAL public/dashboard.html STRING CHECK ==="
  awk '/=== LOCAL public\/dashboard.html STRING CHECK ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST_COMPARE}" | sed '/^[[:space:]]*$/d' || true
  echo

  echo "=== HASHES ==="
  awk '/=== HASHES ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST_COMPARE}" | sed '/^[[:space:]]*$/d' || true
  echo

  echo "=== PORT 8080 OWNER ==="
  awk '/=== PORT 8080 OWNER ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST_COMPARE}" | sed '/^[[:space:]]*$/d' || true
  echo

  echo "=== PM2 STATUS ==="
  awk '/=== PM2 STATUS ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST_COMPARE}" | sed '/^[[:space:]]*$/d' || true
  echo

  echo "=== VERDICT ==="
  if rg -q "Confidence: insufficient" "${LATEST_SERVED}" 2>/dev/null; then
    echo "served_html_contains_confidence_insufficient=YES"
  else
    echo "served_html_contains_confidence_insufficient=NO"
  fi

  if rg -q "Confidence: insufficient" public/dashboard.html 2>/dev/null; then
    echo "public_dashboard_contains_confidence_insufficient=YES"
  else
    echo "public_dashboard_contains_confidence_insufficient=NO"
  fi
  echo

  echo "=== INTERPRETATION ==="
  echo "If served_html_contains_confidence_insufficient=YES and public_dashboard_contains_confidence_insufficient=NO,"
  echo "the active server is serving a different artifact than public/dashboard.html."
  echo
} > "${OUT}"

echo "${OUT}"
