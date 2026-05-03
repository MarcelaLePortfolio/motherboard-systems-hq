#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path
import re

targets = [
    Path("public/js/agent-status-row.js"),
    Path("public/bundle.js"),
]

marker = "PHASE62B_METRIC_LABEL_FIX"
pattern = re.compile(
    r'\n?;\/\*\s*' + re.escape(marker) + r'\s*\*\/\s*\(\(\)\s*=>\s*\{.*?\}\)\(\);\s*',
    re.DOTALL
)

for path in targets:
    text = path.read_text()
    new_text, count = pattern.subn('\n', text)
    if count == 0:
        print(f"no-op: {marker} not found in {path}")
    else:
        path.write_text(new_text.rstrip() + "\n")
        print(f"removed {marker} from {path}")
PY
