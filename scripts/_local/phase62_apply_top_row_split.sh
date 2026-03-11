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

section_pat = re.compile(r"</?section\b[^>]*>", re.IGNORECASE | re.DOTALL)

def find_matching_section_end(src: str, open_start: int) -> int:
    depth = 0
    started = False
    for m in section_pat.finditer(src, open_start):
        token = m.group(0).lower()
        if token.startswith("<section"):
            depth += 1
            started = True
        elif token.startswith("</section"):
            depth -= 1
            if started and depth == 0:
                return m.end()
    raise RuntimeError("unbalanced <section> structure")

metrics_open = re.search(r'<section[^>]*id="metrics-row"[^>]*>', text, re.IGNORECASE)
workspace_open = re.search(r'<section[^>]*id="phase61-workspace-shell"[^>]*>', text, re.IGNORECASE)

if not metrics_open or not workspace_open:
    print("required structural anchors not found", file=sys.stderr)
    sys.exit(1)

metrics_start = metrics_open.start()
metrics_end = find_matching_section_end(text, metrics_start)
workspace_start = workspace_open.start()

agent_open = None
for m in re.finditer(r'<section\b[^>]*>', text[metrics_end:workspace_start], re.IGNORECASE):
    candidate_start = metrics_end + m.start()
    candidate_end = find_matching_section_end(text, candidate_start)
    if candidate_end <= workspace_start:
        agent_open = candidate_start
        agent_end = candidate_end
        break

if agent_open is None:
    print("could not locate top-row section between metrics row and workspace shell", file=sys.stderr)
    sys.exit(1)

metrics_block = text[metrics_start:metrics_end]
agent_block = text[agent_open:agent_end]

wrapper = (
    '<section class="phase62-top-row" data-phase="62">\n'
    '  <div class="phase62-top-col phase62-top-col--agents">\n'
    f'{agent_block}\n'
    '  </div>\n'
    '  <div class="phase62-top-col phase62-top-col--metrics">\n'
    f'{metrics_block}\n'
    '  </div>\n'
    '</section>\n\n'
)

text = text[:metrics_start] + text[metrics_end:agent_open] + text[agent_end:]
text = text[:metrics_start] + wrapper + text[metrics_start:]

if "</style>" in text:
    text = text.replace("</style>", f"\n{style_snippet}\n</style>", 1)
elif "</head>" in text:
    text = text.replace("</head>", f"<style>\n{style_snippet}\n</style>\n</head>", 1)
else:
    print("no </style> or </head> found for CSS injection", file=sys.stderr)
    sys.exit(1)

required = [
    'class="phase62-top-row"',
    'id="metrics-row"',
    'id="phase61-workspace-shell"',
    'id="phase61-workspace-grid"',
    'id="operator-workspace-card"',
    'id="observational-workspace-card"',
    'id="atlas-status-card"',
    'Operator Workspace',
    'Telemetry Workspace',
    'Atlas Subsystem Status',
    'Matilda',
    'Atlas',
    'Cade',
    'Effie',
]

for needle in required:
    if needle not in text:
        print(f"missing required content after rewrite: {needle}", file=sys.stderr)
        sys.exit(1)

html_path.write_text(text)
PY

"$VERIFY_SCRIPT" "$HTML_FILE"
