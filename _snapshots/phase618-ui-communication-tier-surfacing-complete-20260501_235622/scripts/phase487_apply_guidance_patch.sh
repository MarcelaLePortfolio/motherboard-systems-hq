#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

TARGET="src/cognition/operatorGuidanceMapping.ts"

if [ ! -f "${TARGET}" ]; then
  echo "Target file not found: ${TARGET}"
  exit 1
fi

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_patch_application_${STAMP}.txt"

cp "${TARGET}" "/tmp/operatorGuidanceMapping.backup.${STAMP}.ts"

python3 - <<PY
from pathlib import Path
path = Path("${TARGET}")
text = path.read_text()

old = '`Signal quality is limited; interpret with caution: ${signal.summary}`'

# Replace with guarded neutral rendering (no premature insufficiency framing)
new = '''
(signal.summary
  ? `Signal quality is limited; interpret with caution: ${signal.summary}`
  : `Signal quality currently unavailable; awaiting stronger signal.`
)
'''.strip()

if old not in text:
    raise SystemExit("Expected previously patched string not found; aborting for safety.")

text = text.replace(old, new, 1)

path.write_text(text)
PY

{
  echo "PHASE 487 — GUIDANCE PATCH APPLICATION"
  echo "timestamp=${STAMP}"
  echo "target_file=${TARGET}"
  echo

  echo "=== PATCH TYPE ==="
  echo "Convert static message into guarded conditional rendering"
  echo

  echo "=== BEFORE ==="
  echo 'Signal quality is limited; interpret with caution: ${signal.summary}'
  echo

  echo "=== AFTER ==="
  echo '(signal.summary ? caution message : neutral unavailable message)'
  echo

  echo "=== INTENT ==="
  echo "Prevent premature or misleading guidance when signal is absent or weak."
  echo "Preserve existing contracts."
  echo "UI-only change."
  echo
} > "${OUT}"

echo "${OUT}"
