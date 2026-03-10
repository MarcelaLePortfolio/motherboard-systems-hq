#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path
import re
import shutil

p = Path("public/dashboard.html")
if not p.exists():
    raise SystemExit("public/dashboard.html not found")

html = p.read_text(encoding="utf-8")
backup = p.with_suffix(".html.bak.phase61_clean_rewrite")
shutil.copy2(p, backup)

required_strings = [
    '<main',
    '</main>',
    'Operator Workspace',
    'Recent Tasks',
    'Task Events',
    'Atlas Subsystem Status',
]
for s in required_strings:
    if s not in html:
        raise SystemExit(f"required anchor missing: {s}")

main_match = re.search(r'(<main\b[^>]*>)(.*?)(</main>)', html, flags=re.S | re.I)
if not main_match:
    raise SystemExit("main region not found")

main_open, main_body, main_close = main_match.groups()

metrics_anchor = '<section class="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">'
metrics_idx = main_body.find(metrics_anchor)
if metrics_idx == -1:
    raise SystemExit("metrics row anchor not found")

metrics_close_rel = main_body.find('</section>', metrics_idx)
if metrics_close_rel == -1:
    raise SystemExit("metrics row close not found")
metrics_end = metrics_close_rel + len('</section>')

obs_label = 'Observational Workspace' if 'Observational Workspace' in main_body else 'Telemetry Workspace'

def find_container_bounds(body: str, anchor: str):
    anchor_pos = body.find(anchor)
    if anchor_pos == -1:
        raise SystemExit(f"anchor not found: {anchor}")
    tags = list(re.finditer(r'</?(section|div|article)\b[^>]*>', body, flags=re.I))
    stack = []
    chosen = None
    for m in tags:
        token = m.group(0)
        if not token.startswith("</"):
            stack.append((m.group(1).lower(), m.start(), m.end(), token))
        else:
            if not stack:
                continue
            open_tag = stack.pop()
            if open_tag[1] <= anchor_pos <= m.end():
                chosen = (open_tag[1], m.end(), open_tag[3], token)
    if chosen is None:
        raise SystemExit(f"container bounds not found for: {anchor}")
    return chosen[0], chosen[1]

operator_start, operator_end = find_container_bounds(main_body, 'Operator Workspace')
obs_start, obs_end = find_container_bounds(main_body, obs_label)
atlas_start, atlas_end = find_container_bounds(main_body, 'Atlas Subsystem Status')

operator_html = main_body[operator_start:operator_end]
obs_html = main_body[obs_start:obs_end]
atlas_html = main_body[atlas_start:atlas_end]

def ensure_id(block: str, desired_id: str):
    if re.search(rf'\bid=["\']{re.escape(desired_id)}["\']', block):
        return block
    return re.sub(
        r'^<([a-zA-Z0-9]+)\b',
        rf'<\1 id="{desired_id}"',
        block,
        count=1,
        flags=re.S
    )

operator_html = ensure_id(operator_html, 'operator-workspace-card')
obs_html = ensure_id(obs_html, 'observational-workspace-card')
atlas_html = ensure_id(atlas_html, 'atlas-subsystem-status-card')

new_workspace = f'''
<section id="phase61-workspace-shell" class="space-y-4">
  <div id="phase61-workspace-grid">
    {operator_html}
    {obs_html}
  </div>
  <section id="phase61-atlas-band">
    {atlas_html}
  </section>
</section>
'''.strip()

replace_start = metrics_end
replace_end = max(operator_end, obs_end, atlas_end)

new_main_body = main_body[:replace_start] + '\n\n' + new_workspace + '\n' + main_body[replace_end:]

new_main_body = re.sub(
    r'(<section id="phase61-workspace-shell"[\s\S]*?</section>\s*</section>)(?=[\s\S]*<section id="phase61-workspace-shell")',
    '',
    new_main_body,
    flags=re.I
)

css = """
/* phase61 deterministic workspace rewrite */
#phase61-workspace-shell {
  width: 100%;
}

#phase61-workspace-grid {
  display: grid;
  grid-template-columns: minmax(0, 1fr) minmax(0, 1fr);
  gap: 16px;
  align-items: start;
  width: 100%;
}

#phase61-atlas-band {
  width: 100%;
  margin-top: 16px;
}

#operator-workspace-card,
#observational-workspace-card,
#atlas-subsystem-status-card {
  min-width: 0;
  width: 100%;
}

@media (max-width: 1100px) {
  #phase61-workspace-grid {
    grid-template-columns: 1fr;
  }
}
""".strip()

if '#phase61-workspace-grid' not in html:
    if '</style>' in html:
        html = html.replace('</style>', '\n' + css + '\n</style>', 1)
    elif '</head>' in html:
        html = html.replace('</head>', '<style>\n' + css + '\n</style>\n</head>', 1)
    else:
        raise SystemExit("no style/head target for css injection")

new_html = html.replace(main_match.group(0), f'{main_open}{new_main_body}{main_close}', 1)
p.write_text(new_html, encoding='utf-8')
print("phase61 workspace region cleanly rewritten")
PY
