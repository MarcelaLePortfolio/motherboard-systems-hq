#!/usr/bin/env bash
set -euo pipefail

HTML_FILE="public/dashboard.html"
VERIFY_SCRIPT="scripts/verify-dashboard-layout-contract.sh"

if [[ ! -f "$HTML_FILE" ]]; then
  echo "missing $HTML_FILE" >&2
  exit 1
fi

"$VERIFY_SCRIPT" "$HTML_FILE"

cp "$HTML_FILE" "${HTML_FILE}.phase62-refine-metrics.bak.$(date +%Y%m%d%H%M%S)"

python3 <<'PY'
from pathlib import Path
import re
import sys

path = Path("public/dashboard.html")
text = path.read_text()

if 'phase62-metric-tile' in text:
    print("phase62 metric tile styling already present; refusing to patch forward", file=sys.stderr)
    sys.exit(1)

style_snippet = """
  /* Phase 62: telemetry tile refinement */
  #metrics-row.phase62-metrics-tiles {
    gap: 12px;
    align-items: stretch;
  }

  #metrics-row.phase62-metrics-tiles > div {
    min-height: 84px;
  }

  .phase62-metric-tile {
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }

  .phase62-metric-value {
    font-size: 1.875rem;
    line-height: 1;
    letter-spacing: -0.02em;
  }

  .phase62-metric-label {
    font-size: 0.7rem;
    line-height: 1rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
  }
""".strip("\n")

replacements = [
    (
        'id="metrics-row"\n      class="grid grid-cols-2 gap-3 auto-rows-fr"',
        'id="metrics-row"\n      class="phase62-metrics-tiles grid grid-cols-2 gap-3 auto-rows-fr"',
    ),
    (
        'class="bg-gray-800 p-3 rounded-2xl shadow-lg border border-gray-700 min-h-[88px] flex flex-col justify-between"',
        'class="phase62-metric-tile bg-gray-800 p-3 rounded-2xl shadow-lg border border-gray-700 min-h-[84px] flex flex-col justify-between"',
    ),
    (
        'class="text-xs uppercase tracking-wide text-gray-400"',
        'class="phase62-metric-label text-xs uppercase tracking-wide text-gray-400"',
    ),
    (
        'class="text-xl font-bold text-blue-400 leading-none"',
        'class="phase62-metric-value text-3xl font-bold text-blue-400 leading-none"',
    ),
    (
        'class="text-xl font-bold text-yellow-400 leading-none"',
        'class="phase62-metric-value text-3xl font-bold text-yellow-400 leading-none"',
    ),
    (
        'class="text-xl font-bold text-green-400 leading-none"',
        'class="phase62-metric-value text-3xl font-bold text-green-400 leading-none"',
    ),
    (
        'class="text-xl font-bold text-red-400 leading-none"',
        'class="phase62-metric-value text-3xl font-bold text-red-400 leading-none"',
    ),
]

for old, new in replacements:
    if old not in text:
        print(f"expected metrics fragment not found: {old}", file=sys.stderr)
        sys.exit(1)
    text = text.replace(old, new, 1)

if "</style>" in text:
    text = text.replace("</style>", f"\n{style_snippet}\n</style>", 1)
elif "</head>" in text:
    text = text.replace("</head>", f"<style>\n{style_snippet}\n</style>\n</head>", 1)
else:
    print("no </style> or </head> found for CSS injection", file=sys.stderr)
    sys.exit(1)

required = [
    'phase62-metrics-tiles',
    'phase62-metric-tile',
    'phase62-metric-label',
    'phase62-metric-value text-3xl font-bold text-blue-400 leading-none',
    'phase62-metric-value text-3xl font-bold text-yellow-400 leading-none',
    'phase62-metric-value text-3xl font-bold text-green-400 leading-none',
    'phase62-metric-value text-3xl font-bold text-red-400 leading-none',
]

for needle in required:
    if needle not in text:
        print(f"missing expected refined metrics content: {needle}", file=sys.stderr)
        sys.exit(1)

path.write_text(text)
PY

"$VERIFY_SCRIPT" "$HTML_FILE"
docker compose build dashboard
docker compose up -d dashboard
