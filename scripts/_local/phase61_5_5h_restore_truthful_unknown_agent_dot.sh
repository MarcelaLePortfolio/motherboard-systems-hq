#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

python3 <<'PY'
from pathlib import Path

path = Path("public/js/agent-status-row.js")
text = path.read_text()

yellow = 'indicator.bar.style.background = "rgba(252,211,77,0.95)";'
gray = 'indicator.bar.style.background = "rgba(148,163,184,0.8)";'

count = text.count(yellow)
if count == 0:
    raise SystemExit("expected yellow fallback dot color not found")

text = text.replace(yellow, gray, 1)
path.write_text(text)

print(f"restored truthful unknown fallback color to gray (replaced {1} default occurrence)")
PY

npm run build:dashboard-bundle
