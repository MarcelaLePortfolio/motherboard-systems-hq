#!/usr/bin/env bash
set -euo pipefail

HTML_FILE="public/dashboard.html"
VERIFY_SCRIPT="scripts/verify-dashboard-layout-contract.sh"

if [[ ! -f "$HTML_FILE" ]]; then
  echo "missing $HTML_FILE" >&2
  exit 1
fi

"$VERIFY_SCRIPT" "$HTML_FILE"

cp "$HTML_FILE" "${HTML_FILE}.phase62-consolidate-metrics-css.bak.$(date +%Y%m%d%H%M%S)"

python3 <<'PY'
from pathlib import Path
import re
import sys

path = Path("public/dashboard.html")
text = path.read_text()

text = re.sub(
    r'\n\s*/\*\s*Phase 62: telemetry tile refinement\s*\*/.*?(?=\n\s*/\*|\n</style>)',
    '',
    text,
    flags=re.DOTALL,
)
text = re.sub(
    r'\n\s*/\*\s*Phase 62: promote metric values to telemetry-first tiles\s*\*/.*?(?=\n\s*/\*|\n</style>)',
    '',
    text,
    flags=re.DOTALL,
)

required_markup = [
    'id="metrics-row"',
    'phase62-metrics-tiles',
    'phase62-metric-card',
    'phase62-metric-value',
    'phase62-metric-label',
    'id="metric-agents"',
    'id="metric-tasks"',
    'id="metric-success-rate"',
    'id="metric-latency"',
]
for needle in required_markup:
    if needle not in text:
        print(f"missing required metrics markup: {needle}", file=sys.stderr)
        sys.exit(1)

style_snippet = """
  /* Phase 62: consolidated metrics telemetry tile styling */
  #metrics-row.phase62-metrics-tiles {
    display: grid !important;
    grid-template-columns: repeat(2, minmax(0, 1fr)) !important;
    gap: 12px !important;
    align-items: stretch !important;
  }

  #metrics-row.phase62-metrics-tiles > .phase62-metric-card,
  #metrics-row.phase62-metrics-tiles > .phase62-metric-tile,
  #metrics-row.phase62-metrics-tiles > div.phase62-metric-card {
    min-height: 72px !important;
    padding: 12px 12px 10px 12px !important;
    display: flex !important;
    flex-direction: column !important;
    justify-content: flex-start !important;
    align-items: flex-start !important;
    gap: 8px !important;
  }

  #metrics-row.phase62-metrics-tiles .phase62-metric-value {
    order: 1 !important;
    font-size: 2.5rem !important;
    line-height: 1 !important;
    letter-spacing: -0.04em !important;
    margin: 0 !important;
  }

  #metrics-row.phase62-metrics-tiles .phase62-metric-label {
    order: 2 !important;
    font-size: 0.68rem !important;
    line-height: 0.9rem !important;
    text-transform: uppercase !important;
    letter-spacing: 0.08em !important;
    opacity: 0.82 !important;
    margin: 0 !important;
  }
""".strip("\n")

if "</style>" in text:
    text = text.replace("</style>", f"\n{style_snippet}\n</style>", 1)
elif "</head>" in text:
    text = text.replace("</head>", f"<style>\n{style_snippet}\n</style>\n</head>", 1)
else:
    print("no </style> or </head> found for CSS injection", file=sys.stderr)
    sys.exit(1)

required_css = [
    "Phase 62: consolidated metrics telemetry tile styling",
    "font-size: 2.5rem !important;",
    "min-height: 72px !important;",
]
for needle in required_css:
    if needle not in text:
        print(f"missing required CSS fragment: {needle}", file=sys.stderr)
        sys.exit(1)

path.write_text(text)
PY

"$VERIFY_SCRIPT" "$HTML_FILE"
docker compose build --no-cache dashboard
docker compose up -d --force-recreate dashboard
