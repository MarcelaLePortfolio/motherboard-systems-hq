#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path
import re

path = Path("public/dashboard.html")
text = path.read_text()

metrics = [
    "Active Agents",
    "Tasks Running",
    "Success Rate",
    "Latency",
    "Latency (ms)",
]

for label in metrics:
    pattern = re.compile(
        rf'(\s*<[^>]+class="[^"]*\bphase62-metric-card\b[^"]*"[^>]*>\s*)'
        rf'<p[^>]*class="[^"]*\bphase62-metric-label\b[^"]*"[^>]*>\s*{re.escape(label)}\s*</p>'
        rf'(\s*<p[^>]*class="[^"]*\bphase62-metric-value\b[^"]*"[^>]*>.*?</p>\s*'
        rf'<p[^>]*class="[^"]*\bphase62-metric-label\b[^"]*"[^>]*>\s*{re.escape(label)}\s*</p>)',
        re.IGNORECASE | re.DOTALL
    )
    text, count = pattern.subn(r'\1\2', text)

path.write_text(text)
print("patched public/dashboard.html")
PY
