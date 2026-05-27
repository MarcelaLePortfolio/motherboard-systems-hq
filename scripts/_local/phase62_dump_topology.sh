#!/usr/bin/env bash
set -euo pipefail

HTML_FILE="public/dashboard.html"

if [[ ! -f "$HTML_FILE" ]]; then
  echo "missing $HTML_FILE" >&2
  exit 1
fi

python3 <<'PY'
from pathlib import Path
import re

text = Path("public/dashboard.html").read_text()

targets = [
    'id="metrics-row"',
    'id="phase61-workspace-shell"',
    'id="phase61-workspace-grid"',
    'id="operator-workspace-card"',
    'id="observational-workspace-card"',
    'id="atlas-status-card"',
    'Agent Pool',
    'System Metrics',
    'Matilda',
    'Atlas',
    'Cade',
    'Effie',
]

for needle in targets:
    idx = text.find(needle)
    print(f"\n===== {needle} =====")
    if idx == -1:
      print("NOT FOUND")
      continue
    start = max(0, idx - 500)
    end = min(len(text), idx + 1200)
    print(text[start:end])
PY
