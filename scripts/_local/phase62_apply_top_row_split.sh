#!/usr/bin/env bash
set -euo pipefail

HTML_FILE="public/dashboard.html"
VERIFY_SCRIPT="scripts/verify-dashboard-layout-contract.sh"

if [[ ! -f "$HTML_FILE" ]]; then
  echo "missing $HTML_FILE" >&2
  exit 1
fi

if [[ ! -x "$VERIFY_SCRIPT" ]]; then
  chmod +x "$VERIFY_SCRIPT"
fi

"$VERIFY_SCRIPT" "$HTML_FILE"

cp "$HTML_FILE" "${HTML_FILE}.phase62.bak.$(date +%Y%m%d%H%M%S)"

python3 <<'PY'
from pathlib import Path
import re
import sys

html_path = Path("public/dashboard.html")
text = html_path.read_text()

if "phase62-top-row" in text:
    print("phase62-top-row already present; refusing to patch forward", file=sys.stderr)
    sys.exit(1)

style_snippet = """
  /* Phase 62: top-row density split */
  .phase62-top-row {
    display: grid;
    grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
    gap: 16px;
    align-items: stretch;
    margin-bottom: 16px;
  }

  .phase62-top-col {
    min-width: 0;
  }

  .phase62-top-col > * {
    height: 100%;
  }

  @media (max-width: 1100px) {
    .phase62-top-row {
      grid-template-columns: 1fr;
    }
  }
""".strip("\n")

metrics_open = re.search(r'<section[^>]*id="metrics-row"[^>]*>', text)
workspace_shell = re.search(r'<section[^>]*id="phase61-workspace-shell"[^>]*>', text)

if not metrics_open or not workspace_shell:
    print("required structural anchors not found", file=sys.stderr)
    sys.exit(1)

insert_at = workspace_shell.start()

agent_match = re.search(r'(?P<block><section[^>]*>\s*<div[^>]*class="[^"]*\bcard-header\b[^"]*"[^>]*>.*?<h[1-6][^>]*>\s*Agent Pool\s*</h[1-6]>.*?</section>)', text, re.DOTALL | re.IGNORECASE)
metrics_match = re.search(r'(?P<block><section[^>]*id="metrics-row"[^>]*>.*?</section>)', text, re.DOTALL | re.IGNORECASE)

if not agent_match or not metrics_match:
    print("could not locate Agent Pool or System Metrics blocks", file=sys.stderr)
    sys.exit(1)

agent_block = agent_match.group("block")
metrics_block = metrics_match.group("block")

if agent_block == metrics_block:
    print("agent and metrics blocks resolved identically", file=sys.stderr)
    sys.exit(1)

for block in sorted([agent_block, metrics_block], key=len, reverse=True):
    if block not in text:
        print("expected block missing before rewrite", file=sys.stderr)
        sys.exit(1)
    text = text.replace(block, "", 1)

wrapper = f'''
<section class="phase62-top-row" data-phase="62">
  <div class="phase62-top-col phase62-top-col--agents">
{agent_block}
  </div>
  <div class="phase62-top-col phase62-top-col--metrics">
{metrics_block}
  </div>
</section>

'''.lstrip("\n")

text = text[:insert_at] + wrapper + text[insert_at:]

if "</style>" in text:
    text = text.replace("</style>", f"\n{style_snippet}\n</style>", 1)
elif "</head>" in text:
    text = text.replace("</head>", f"<style>\n{style_snippet}\n</style>\n</head>", 1)
else:
    print("no </style> or </head> found for CSS injection", file=sys.stderr)
    sys.exit(1)

required = [
    'class="phase62-top-row"',
    'Agent Pool',
    'System Metrics',
    'id="phase61-workspace-shell"',
    'id="phase61-workspace-grid"',
    'id="operator-workspace-card"',
    'id="observational-workspace-card"',
    'id="atlas-status-card"',
]

for needle in required:
    if needle not in text:
        print(f"missing required content after rewrite: {needle}", file=sys.stderr)
        sys.exit(1)

html_path.write_text(text)
PY

"$VERIFY_SCRIPT" "$HTML_FILE"
