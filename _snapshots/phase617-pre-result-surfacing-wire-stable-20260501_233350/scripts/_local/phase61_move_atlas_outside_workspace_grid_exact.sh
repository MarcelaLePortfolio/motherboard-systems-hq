#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path
import re
import shutil

p = Path("public/dashboard.html")
html = p.read_text(encoding="utf-8")
backup = p.with_name("dashboard.html.bak.phase61_move_atlas_outside_workspace_grid_exact")
shutil.copy2(p, backup)

original = html

atlas_match = re.search(
    r'<section id="atlas-status-card" class="bg-gray-800 p-6 rounded-2xl shadow-lg border border-gray-700">.*?</section>',
    html,
    flags=re.S,
)
if not atlas_match:
    raise SystemExit("atlas-status-card block not found")

atlas_block = atlas_match.group(0)

html = html[:atlas_match.start()] + html[atlas_match.end():]

html = re.sub(
    r'\s*<section aria-label="Subsystem status" class="space-y-4">\s*</section>\s*',
    '\n',
    html,
    count=1,
    flags=re.S,
)

tail_pattern = r'</section>\s*</main>'
replacement = (
    '</div>\n'
    '      <section id="phase61-atlas-band" class="space-y-4">\n'
    f'        {atlas_block}\n'
    '      </section>\n'
    '    </section>\n'
    '    </main>'
)

html, count = re.subn(tail_pattern, replacement, html, count=1, flags=re.S)
if count != 1:
    raise SystemExit("could not rewrite workspace-shell/main closing region")

if '#phase61-atlas-band' not in html:
    raise SystemExit("phase61-atlas-band missing after rewrite")

if html == original:
    raise SystemExit("no changes applied")

p.write_text(html, encoding="utf-8")
print("Moved Atlas outside workspace grid and into bottom band.")
PY

git diff -- public/dashboard.html || true
