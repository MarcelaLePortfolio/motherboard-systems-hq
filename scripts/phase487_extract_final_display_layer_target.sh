#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST="$(ls -t docs/phase487_trace_exact_visible_card_literals_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST}" ]; then
  echo "No exact visible card literal trace found."
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_final_display_layer_target_${STAMP}.txt"

{
  echo "PHASE 487 — FINAL DISPLAY LAYER TARGET"
  echo "timestamp=${STAMP}"
  echo "source_file=${LATEST}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  echo "=== DASHBOARD-ONLY CANDIDATES ==="
  awk '/=== DASHBOARD-ONLY CANDIDATES ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' | sort -u
  echo

  echo "=== EXACT VISIBLE STRING MATCHES ==="
  awk '/=== EXACT VISIBLE STRINGS ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' | head -n 200
  echo

  echo "=== CONFIDENCE FORMATTER MATCHES ==="
  awk '/=== CONFIDENCE FORMATTERS ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" | sed '/^[[:space:]]*$/d' | head -n 220
  echo

  echo "=== RECOMMENDED PATCH FILE ==="
  awk '/=== DASHBOARD-ONLY CANDIDATES ===/{flag=1;next}/^=== /{if(flag){exit}}flag' "${LATEST}" \
    | sed '/^[[:space:]]*$/d' \
    | grep -E 'dashboard/src|app/|ui/' \
    | head -n 1
  echo

  echo "=== NEXT ACTION ==="
  echo "Patch only the recommended display-layer file above."
  echo "Do not modify mapping or runtime layers in the next step."
  echo
} > "${OUT}"

echo "${OUT}"
