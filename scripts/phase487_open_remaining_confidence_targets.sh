#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST_TRACE="$(ls -t docs/phase487_confidence_render_surface_*.txt 2>/dev/null | head -n 1 || true)"
LATEST_VERDICT="$(ls -t docs/phase487_confidence_render_verdict_*.txt 2>/dev/null | head -n 1 || true)"

if [ -z "${LATEST_TRACE}" ] || [ -z "${LATEST_VERDICT}" ]; then
  echo "Required Phase 487 confidence evidence files not found."
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_remaining_confidence_targets_${STAMP}.txt"
TMP="$(mktemp)"

grep -nE "insufficient|Confidence:|confidenceLabel|diagnostics/system-health|system-health|system_health" "${LATEST_TRACE}" \
  | grep -E "app/|src/|ui/|lib/|pages/" \
  | sed -E 's#^.*((app|src|ui|lib|pages)/[^:]+:[0-9]+:.*)$#\1#' \
  | head -n 120 > "${TMP}" || true

{
  echo "PHASE 487 — REMAINING CONFIDENCE TARGETS"
  echo "timestamp=${STAMP}"
  echo "trace_file=${LATEST_TRACE}"
  echo "verdict_file=${LATEST_VERDICT}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== TOP RAW TARGET LINES ==="
  cat "${TMP}" || true
  echo

  echo "=== SOURCE WINDOWS ==="
  while IFS= read -r hit; do
    [ -n "${hit}" ] || continue
    file="$(printf '%s' "${hit}" | cut -d: -f1)"
    line="$(printf '%s' "${hit}" | cut -d: -f2)"
    [ -f "${file}" ] || continue
    start=$(( line > 8 ? line - 8 : 1 ))
    end=$(( line + 8 ))
    echo "----- ${file}:${start}-${end} -----"
    sed -n "${start},${end}p" "${file}" || true
    echo
  done < <(printf '%s\n' "$(cat "${TMP}")" | awk -F: '!seen[$1 ":" $2]++')
  echo

  echo "=== DECISION TARGET ==="
  echo "Identify the remaining render surface that still maps confidence to insufficient."
  echo "Patch only the display-layer source file that renders the confidence badge."
  echo
} > "${OUT}"

rm -f "${TMP}"

echo "${OUT}"
