#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

python3 <<'PY'
from pathlib import Path

path = Path("public/js/agent-status-row.js")
text = path.read_text()

old = 'indicator.bar.style.background = "rgba(148,163,184,0.8)";'
new = 'indicator.bar.style.background = "rgba(252,211,77,0.95)";'

if old not in text:
    raise SystemExit("expected gray default dot not found")

text = text.replace(old, new, 1)
path.write_text(text)

print("default agent dot color restored to pending/yellow")
PY
