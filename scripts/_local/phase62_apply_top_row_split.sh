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

if 'class="phase62-top-row"' in text:
    print("phase62-top-row already present; refusing to patch forward", file=sys.stderr)
    sys.exit(1)

style_snippet = """
  /* Phase 62: Agent Pool + Metrics dual top row */
  .phase62-top-row {
    display: grid;
    grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
    gap: 16px;
    align-items: stretch;
  }

  .phase62-top-col {
    min-width: 0;
  }

  .phase62-top-col > section,
  .phase62-top-col > div {
    height: 100%;
    margin-bottom: 0 !important;
  }

  #agent-status-container.phase62-agent-pool {
    margin-bottom: 0 !important;
  }

  @media (max-width: 1100px) {
    .phase62-top-row {
      grid-template-columns: 1fr;
    }
  }
""".strip("\n")

section_pat = re.compile(r'<section\b[^>]*>|</section>', re.IGNORECASE | re.DOTALL)

def section_bounds_by_id(src: str, element_id: str):
    open_pat = re.compile(rf'<section[^>]*id="{re.escape(element_id)}"[^>]*>', re.IGNORECASE | re.DOTALL)
    m = open_pat.search(src)
    if not m:
        raise RuntimeError(f"section with id={element_id!r} not found")
    depth = 0
    started = False
    for tok in section_pat.finditer(src, m.start()):
        token = tok.group(0).lower()
        if token.startswith("<section"):
            depth += 1
            started = True
        else:
            depth -= 1
            if started and depth == 0:
                return m.start(), tok.end()
    raise RuntimeError(f"unbalanced section structure for id={element_id!r}")

agent_start, agent_end = section_bounds_by_id(text, "agent-status-container")
metrics_start, metrics_end = section_bounds_by_id(text, "metrics-row")

agent_block = text[agent_start:agent_end]
metrics_block = text[metrics_start:metrics_end]

agent_block = agent_block.replace(
    'id="agent-status-container"',
    'id="agent-status-container" class="phase59-shell phase62-agent-pool bg-gray-800 p-4 rounded-2xl shadow-2xl flex flex-wrap gap-4 items-center border border-gray-700"',
    1
) if 'class="phase59-shell bg-gray-800 p-4 rounded-2xl shadow-2xl flex flex-wrap gap-4 items-center mb-6 border border-gray-700"' in agent_block else agent_block.replace(
    'id="agent-status-container"',
    'id="agent-status-container"',
    1
)

agent_block = agent_block.replace(' mb-6 ', ' ', 1).replace(' mb-6"', '"')

wrapper = (
    '    <section class="phase62-top-row" data-phase="62">\n'
    '      <div class="phase62-top-col phase62-top-col--agents">\n'
    f'{agent_block}\n'
    '      </div>\n'
    '      <div class="phase62-top-col phase62-top-col--metrics">\n'
    f'{metrics_block}\n'
    '      </div>\n'
    '    </section>\n'
)

for start, end in sorted([(agent_start, agent_end), (metrics_start, metrics_end)], reverse=True):
    text = text[:start] + text[end:]

main_match = re.search(r'<main\b[^>]*class="phase59-shell space-y-6"[^>]*>', text, re.IGNORECASE)
if not main_match:
    print("phase59 main shell not found", file=sys.stderr)
    sys.exit(1)

insert_at = main_match.end()
text = text[:insert_at] + "\n" + wrapper + text[insert_at:]

if "</style>" in text:
    text = text.replace("</style>", f"\n{style_snippet}\n</style>", 1)
elif "</head>" in text:
    text = text.replace("</head>", f"<style>\n{style_snippet}\n</style>\n</head>", 1)
else:
    print("no </style> or </head> found for CSS injection", file=sys.stderr)
    sys.exit(1)

required = [
    'class="phase62-top-row"',
    'id="agent-status-container"',
    'id="metrics-row"',
    'id="phase61-workspace-shell"',
    'id="phase61-workspace-grid"',
    'id="operator-workspace-card"',
    'id="observational-workspace-card"',
    'id="atlas-status-card"',
    'Operator Workspace',
    'Telemetry Workspace',
    'Atlas Subsystem Status',
    'Agent Pool',
    'Active Agents',
]

for needle in required:
    if needle not in text:
        print(f"missing required content after rewrite: {needle}", file=sys.stderr)
        sys.exit(1)

html_path.write_text(text)
PY

"$VERIFY_SCRIPT" "$HTML_FILE"
