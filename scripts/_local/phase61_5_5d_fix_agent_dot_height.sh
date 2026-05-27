#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

python3 <<'PY'
from pathlib import Path

path = Path("public/js/agent-status-row.js")
text = path.read_text()

old = 'left.className = "flex items-center gap-3 min-w-0";'
new = 'left.className = "flex items-center gap-3 min-w-0 h-[18px]";'

if old not in text:
    raise SystemExit("expected left container line not found")

text = text.replace(old, new, 1)
path.write_text(text)

print("agent row height constraint applied")
PY
