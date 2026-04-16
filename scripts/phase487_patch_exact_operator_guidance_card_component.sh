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
OUT="docs/phase487_exact_card_component_patch_${STAMP}.txt"
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

if [ -z "${TARGET_FILE}" ]; then
  echo "Operator Guidance card component not found in extracted candidates."
  rm -f "${TMP_FILES}"
  exit 1
fi

cp "${TARGET_FILE}" "/tmp/phase487_operator_guidance_card_before_${STAMP}.patch"

TARGET_FILE_ENV="${TARGET_FILE}" python3 - <<'PY'
from pathlib import Path
import os
import sys

path = Path(os.environ["TARGET_FILE_ENV"])
text = path.read_text()
original = text

replacements = [
    ("Confidence: insufficient", "Confidence: limited"),
    ('confidence: "insufficient"', 'confidence: "limited"'),
    ("confidence: 'insufficient'", "confidence: 'limited'"),
    ('confidenceLabel: "insufficient"', 'confidenceLabel: "limited"'),
    ("confidenceLabel: 'insufficient'", "confidenceLabel: 'limited'"),
    ('return "insufficient";', 'return "limited";'),
    ("return 'insufficient';", "return 'limited';"),
    ('? "insufficient" :', '? "limited" :'),
    ("? 'insufficient' :", "? 'limited' :"),
    (': "insufficient"', ': "limited"'),
    (": 'insufficient'", ": 'limited'"),
]

for old, new in replacements:
    text = text.replace(old, new)

if text == original:
    print("No patchable operator guidance card confidence path found in target file.", file=sys.stderr)
    sys.exit(1)

path.write_text(text)
PY

{
  echo "PHASE 487 — EXACT CARD COMPONENT PATCH"
  echo "timestamp=${STAMP}"
  echo "source_doc=${LATEST_COMPONENT_DOC}"
  echo "target_file=${TARGET_FILE}"
  echo "branch=$(git branch --show-current)"
  echo "commit_before=$(git rev-parse HEAD)"
  echo

  echo "=== DIFF ==="
  diff -u "/tmp/phase487_operator_guidance_card_before_${STAMP}.patch" "${TARGET_FILE}" || true
  echo

  echo "=== SOURCE CHECK ==="
  rg -n -C 3 "Awaiting bounded guidance stream|Live operator guidance will appear here when visibility wiring is active|Confidence:|limited|insufficient" "${TARGET_FILE}" || true
  echo

  echo "=== INTENT ==="
  echo "Patch exact display-layer Operator Guidance card component still emitting Confidence: insufficient."
  echo "UI-only change."
  echo "No backend, governance, approval, or execution mutation."
  echo
} > "${OUT}"

rm -f "${TMP_FILES}"

echo "${OUT}"
