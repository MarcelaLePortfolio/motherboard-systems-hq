#!/usr/bin/env bash
set -euo pipefail

HTML_FILE="public/dashboard.html"
VERIFY_SCRIPT="scripts/verify-dashboard-layout-contract.sh"

if [[ ! -f "$HTML_FILE" ]]; then
  echo "missing $HTML_FILE" >&2
  exit 1
fi

"$VERIFY_SCRIPT" "$HTML_FILE"

cp "$HTML_FILE" "${HTML_FILE}.phase62-compact-metrics.bak.$(date +%Y%m%d%H%M%S)"

python3 <<'PY'
from pathlib import Path
import re
import sys

path = Path("public/dashboard.html")
text = path.read_text()

old_metrics_section = '''<section
      id="metrics-row"
      class="grid grid-cols-2 xl:grid-cols-4 gap-4"
      aria-label="System metrics"
    >'''

new_metrics_section = '''<section
      id="metrics-row"
      class="grid grid-cols-2 gap-3 auto-rows-fr"
      aria-label="System metrics"
    >'''

if old_metrics_section not in text and new_metrics_section not in text:
    print("metrics-row anchor not found in expected form", file=sys.stderr)
    sys.exit(1)

if old_metrics_section in text:
    text = text.replace(old_metrics_section, new_metrics_section, 1)

text = text.replace(
    'class="bg-gray-800 p-4 rounded-2xl shadow-lg border border-gray-700"',
    'class="bg-gray-800 p-3 rounded-2xl shadow-lg border border-gray-700 min-h-[88px] flex flex-col justify-between"',
)

text = text.replace(
    'class="text-sm text-gray-400"',
    'class="text-xs uppercase tracking-wide text-gray-400"',
)

text = text.replace(
    'class="text-2xl font-bold text-blue-400"',
    'class="text-xl font-bold text-blue-400 leading-none"',
)
text = text.replace(
    'class="text-2xl font-bold text-yellow-400"',
    'class="text-xl font-bold text-yellow-400 leading-none"',
)
text = text.replace(
    'class="text-2xl font-bold text-green-400"',
    'class="text-xl font-bold text-green-400 leading-none"',
)
text = text.replace(
    'class="text-2xl font-bold text-red-400"',
    'class="text-xl font-bold text-red-400 leading-none"',
)

required = [
    'id="metrics-row"',
    'grid grid-cols-2 gap-3 auto-rows-fr',
    'min-h-[88px] flex flex-col justify-between',
    'text-xl font-bold text-blue-400 leading-none',
    'text-xl font-bold text-yellow-400 leading-none',
    'text-xl font-bold text-green-400 leading-none',
    'text-xl font-bold text-red-400 leading-none',
]

for needle in required:
    if needle not in text:
        print(f"missing expected compact metrics content: {needle}", file=sys.stderr)
        sys.exit(1)

path.write_text(text)
PY

"$VERIFY_SCRIPT" "$HTML_FILE"
docker compose build dashboard
docker compose up -d dashboard
