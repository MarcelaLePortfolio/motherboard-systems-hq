#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

LATEST_COMPONENT_DOC="$(ls -t docs/phase487_operator_guidance_card_component_*.txt 2>/dev/null | head -n 1 || true)"
if [ -z "${LATEST_COMPONENT_DOC}" ]; then
  echo "No operator guidance card component extraction doc found."
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_reveal_exact_operator_guidance_card_target_${STAMP}.txt"
TMP_FILES="$(mktemp)"

awk '
  /=== UNIQUE SOURCE FILES ===/ {flag=1; next}
  /^=== / {if(flag) exit}
  flag && NF {print}
' "${LATEST_COMPONENT_DOC}" | sed '/^[[:space:]]*$/d' | sort -u > "${TMP_FILES}"

TARGET_FILE=""
while IFS= read -r file; do
  [ -n "${file}" ] || continue
  [ -f "${file}" ] || continue
  if grep -q "Awaiting bounded guidance stream" "${file}" 2>/dev/null || \
     grep -q "Live operator guidance will appear here when visibility wiring is active" "${file}" 2>/dev/null || \
     grep -q "Confidence:" "${file}" 2>/dev/null; then
    TARGET_FILE="${file}"
    break
  fi
done < "${TMP_FILES}"

{
  echo "PHASE 487 — REVEAL EXACT OPERATOR GUIDANCE CARD TARGET"
  echo "timestamp=${STAMP}"
  echo "source_doc=${LATEST_COMPONENT_DOC}"
  echo "target_file=${TARGET_FILE:-NONE}"
  echo "branch=$(git branch --show-current)"
  echo "commit=$(git rev-parse HEAD)"
  echo

  if [ -n "${TARGET_FILE}" ] && [ -f "${TARGET_FILE}" ]; then
    echo "=== TARGET FILE MATCHES ==="
    rg -n -C 8 "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence:|confidence|insufficient|limited|diagnostics/system-health" "${TARGET_FILE}" || true
    echo

    echo "=== TARGET FILE HEAD ==="
    sed -n '1,260p' "${TARGET_FILE}" || true
    echo

    echo "=== TARGET FILE TAIL ==="
    tail -n 260 "${TARGET_FILE}" || true
    echo
  else
    echo "Target file not found from extracted candidates."
    echo
  fi

  echo "=== NEXT READ ==="
  echo "Use this artifact to identify the exact line that renders the visible Confidence value."
  echo
} > "${OUT}"

rm -f "${TMP_FILES}"

echo "${OUT}"
