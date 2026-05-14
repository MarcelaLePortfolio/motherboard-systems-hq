
#!/bin/bash

set -e

echo "===== PHASE 719 ARTIFACT RENDERER INSPECTION ====="

TARGET="public/js/phase530_visible_panels_bridge.js"

echo ""

echo "[1] Git status"

git status --short

echo ""

echo "[2] Current branch"

git branch --show-current

echo ""

echo "[3] Latest commits"

git log --oneline --decorate -5

echo ""

echo "[4] Search artifact preview renderer symbols"

grep -nE "artifact|preview|modal|renderArtifact|artifact-preview|Preview" "$TARGET" | head -120 || true

echo ""

echo "[5] Search renderArtifactPreviewContent if present"

grep -n "renderArtifactPreviewContent" "$TARGET" || true

echo ""

echo "[6] Show artifact-related function blocks"

python3 << 'PY'

from pathlib import Path

import re

path = Path("public/js/phase530_visible_panels_bridge.js")

text = path.read_text()

patterns = [

    r"function\s+\w*[Aa]rtifact\w*\s*\([^)]*\)\s*\{",

    r"const\s+\w*[Aa]rtifact\w*\s*=",

    r"let\s+\w*[Aa]rtifact\w*\s*=",

    r"var\s+\w*[Aa]rtifact\w*\s*=",

]

seen = set()

for pattern in patterns:

    for match in re.finditer(pattern, text):

        start = max(0, match.start() - 500)

        end = min(len(text), match.start() + 2200)

        block = text[start:end]

        if block in seen:

            continue

        seen.add(block)

        print("\\n──────────────── FUNCTION / BLOCK CANDIDATE ────────────────")

        print(block)

if not seen:

    print("No artifact function/block candidates found.")

PY

echo ""

echo "===== INSPECTION COMPLETE ====="

