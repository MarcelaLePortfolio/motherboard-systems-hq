#!/usr/bin/env bash
set -euo pipefail
set +H 2>/dev/null || true

cd "$(git rev-parse --show-toplevel)"

STAMP="$(date +%Y%m%d_%H%M%S)"
OUT="docs/phase487_guidance_confidence_label_repair_${STAMP}.txt"

python3 - <<'PY'
from pathlib import Path
import re
import sys

root = Path(".")
search_dirs = [p for p in [root / "app", root / "src", root / "ui", root / "lib", root / "pages"] if p.exists()]
if not search_dirs:
    search_dirs = [root]

candidates = []
for base in search_dirs:
    for path in base.rglob("*"):
        if path.suffix not in {".ts", ".tsx", ".js", ".jsx"}:
            continue
        text = path.read_text(errors="ignore")
        if "Confidence:" in text or "confidence" in text:
            candidates.append(path)

patched = []
for path in candidates:
    text = path.read_text(errors="ignore")
    original = text

    text = text.replace('Confidence: insufficient', 'Confidence: limited')

    text = re.sub(r'(\bconfidence\s*:\s*)(["\'])insufficient\2', r'\1"limited"', text)
    text = re.sub(r'(\bconfidenceLabel\s*=\s*)(["\'])insufficient\2', r'\1"limited"', text)

    if text != original:
        path.write_text(text)
        patched.append(str(path))

if not patched:
    print("No safe operator-facing confidence label patch target found; aborting.", file=sys.stderr)
    sys.exit(1)

print("patched_files=" + ",".join(patched))
PY

{
  echo "PHASE 487 — GUIDANCE CONFIDENCE LABEL REPAIR"
  echo "timestamp=${STAMP}"
  echo

  echo "=== PATCHED FILES ==="
  rg -n "Confidence:|confidence.*limited" app src ui lib pages 2>/dev/null || true
  echo

  echo "=== INTENT ==="
  echo "Neutralize remaining operator-facing confidence label from insufficient to limited."
  echo "Display-layer only."
  echo "No backend, governance, approval, or execution mutation."
  echo
} > "${OUT}"

echo "${OUT}"
