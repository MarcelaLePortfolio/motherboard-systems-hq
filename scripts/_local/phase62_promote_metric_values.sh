#!/usr/bin/env bash
set -euo pipefail

HTML_FILE="public/dashboard.html"
VERIFY_SCRIPT="scripts/verify-dashboard-layout-contract.sh"

if [[ ! -f "$HTML_FILE" ]]; then
  echo "missing $HTML_FILE" >&2
  exit 1
fi

"$VERIFY_SCRIPT" "$HTML_FILE"

cp "$HTML_FILE" "${HTML_FILE}.phase62-promote-metric-values.bak.$(date +%Y%m%d%H%M%S)"

python3 <<'PY'
from pathlib import Path
import re
import sys

path = Path("public/dashboard.html")
text = path.read_text()

if "phase62-metric-card" in text:
    print("phase62 metric promotion already present; refusing to patch forward", file=sys.stderr)
    sys.exit(1)

metrics_match = re.search(
    r'(<section\s+id="metrics-row"[^>]*>)(.*?)(</section>)',
    text,
    re.DOTALL | re.IGNORECASE,
)
if not metrics_match:
    print("metrics-row section not found", file=sys.stderr)
    sys.exit(1)

metrics_open, metrics_inner, metrics_close = metrics_match.groups()

card_pattern = re.compile(
    r'(<div\s+class=")([^"]*bg-gray-800[^"]*)(">\s*)'
    r'(<p[^>]*class=")([^"]*text-(?:xs|sm)[^"]*text-gray-400[^"]*)(">\s*)(.*?)(\s*</p>\s*)'
    r'(<p[^>]*id=")(metric-[^"]+)(" class=")([^"]*text-(?:xl|2xl|3xl)[^"]*)(">\s*)(.*?)(\s*</p>\s*</div>)',
    re.DOTALL | re.IGNORECASE,
)

cards = list(card_pattern.finditer(metrics_inner))
if len(cards) != 4:
    print(f"expected 4 metric cards, found {len(cards)}", file=sys.stderr)
    sys.exit(1)

def repl(m: re.Match) -> str:
    div_a, div_classes, div_b = m.group(1), m.group(2), m.group(3)
    label_a, label_classes, label_b, label_text, label_close = m.group(4), m.group(5), m.group(6), m.group(7), m.group(8)
    value_a, value_id, value_b, value_classes, value_c, value_text, tail = m.group(9), m.group(10), m.group(11), m.group(12), m.group(13), m.group(14), m.group(15)

    div_classes = div_classes.replace("min-h-[84px]", "min-h-[76px]")
    div_classes = div_classes.replace("min-h-[88px]", "min-h-[76px]")
    if "phase62-metric-card" not in div_classes:
        div_classes = f"phase62-metric-card {div_classes}"

    if "phase62-metric-label" not in label_classes:
        label_classes = f"phase62-metric-label {label_classes}".strip()

    value_classes = re.sub(r'\btext-(?:xl|2xl|3xl)\b', 'text-4xl', value_classes)
    if "phase62-metric-value" not in value_classes:
        value_classes = f"phase62-metric-value {value_classes}".strip()

    return (
        f'{div_a}{div_classes}{div_b}'
        f'{value_a}{value_id}{value_b}{value_classes}{value_c}{value_text}{label_close}'
        f'{label_a}{label_classes}{label_b}{label_text}{tail}'
    )

metrics_inner_new = card_pattern.sub(repl, metrics_inner, count=4)
if metrics_inner_new == metrics_inner:
    print("metric card rewrite made no changes", file=sys.stderr)
    sys.exit(1)

text = text[:metrics_match.start()] + metrics_open + metrics_inner_new + metrics_close + text[metrics_match.end():]

style_snippet = """
  /* Phase 62: promote metric values to telemetry-first tiles */
  #metrics-row.phase62-metrics-tiles {
    gap: 12px;
    align-items: stretch;
  }

  .phase62-metric-card {
    min-height: 76px !important;
    padding-top: 12px !important;
    padding-bottom: 12px !important;
    display: flex;
    flex-direction: column;
    justify-content: space-between;
  }

  .phase62-metric-value {
    font-size: 2.25rem !important;
    line-height: 1 !important;
    letter-spacing: -0.03em;
    order: 1;
  }

  .phase62-metric-label {
    font-size: 0.68rem !important;
    line-height: 0.95rem !important;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    order: 2;
    opacity: 0.88;
  }
""".strip("\n")

if "Phase 62: promote metric values to telemetry-first tiles" not in text:
    if "</style>" in text:
        text = text.replace("</style>", f"\n{style_snippet}\n</style>", 1)
    elif "</head>" in text:
        text = text.replace("</head>", f"<style>\n{style_snippet}\n</style>\n</head>", 1)
    else:
        print("no </style> or </head> found for CSS injection", file=sys.stderr)
        sys.exit(1)

required = [
    "phase62-metric-card",
    "phase62-metric-value",
    "phase62-metric-label",
    'id="metric-agents" class="phase62-metric-value',
    'id="metric-tasks" class="phase62-metric-value',
    'id="metric-success-rate" class="phase62-metric-value',
    'id="metric-latency" class="phase62-metric-value',
]

for needle in required:
    if needle not in text:
        print(f"missing expected promoted metric content: {needle}", file=sys.stderr)
        sys.exit(1)

path.write_text(text)
PY

"$VERIFY_SCRIPT" "$HTML_FILE"
docker compose build dashboard
docker compose up -d dashboard
