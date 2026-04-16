#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST="$(ls -t docs/phase487_operator_guidance_card_literals_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST}" ]; then
  echo "No operator guidance card literal trace found."
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_operator_guidance_card_component_${STAMP}.txt"
TMP="$(mktemp)"

grep -nE "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Sources:|Confidence:|insufficient" "${LATEST}" \
  | sed -E 's#^.*((app|src|ui|lib|pages)/[^:]+:[0-9]+:.*)$#\1#' \
  | grep -E '^(app|src|ui|lib|pages)/' \
  | sort -u > "${TMP}" || true

{
  echo "PHASE 487 — OPERATOR GUIDANCE CARD COMPONENT EXTRACTION"
  echo "timestamp=${STAMP}"
  echo "source_file=${LATEST}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== RAW MATCHES ==="
  cat "${TMP}" || true
  echo

  echo "=== UNIQUE SOURCE FILES ==="
  cut -d: -f1 "${TMP}" | sort -u || true
  echo

  echo "=== SOURCE WINDOWS ==="
  while IFS= read -r hit; do
    [ -n "${hit}" ] || continue
    file="$(printf '%s\n' "${hit}" | cut -d: -f1)"
    line="$(printf '%s\n' "${hit}" | cut -d: -f2)"
    [ -f "${file}" ] || continue
    start=$(( line > 10 ? line - 10 : 1 ))
    end=$(( line + 10 ))
    echo "----- ${file}:${start}-${end} -----"
    sed -n "${start},${end}p" "${file}" || true
    echo
  done < <(awk -F: '!seen[$1 ":" $2]++' "${TMP}")
  echo

  echo "=== DECISION TARGET ==="
  echo "Pick the file that contains the exact visible card literals."
  echo "That file is the remaining display-layer patch target."
  echo
} > "${OUT}"

rm -f "${TMP}"

echo "${OUT}"
