#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path
import re
import shutil

p = Path("public/dashboard.html")
html = p.read_text(encoding="utf-8")
backup = p.with_name("dashboard.html.bak.phase61_atlas_bottom_band")
shutil.copy2(p, backup)

atlas_pattern = re.compile(
    r'\n\s*<section aria-label="Subsystem status" class="space-y-4">\s*</section>\s*'
    r'(\n\s*<section id="atlas-status-card" class="bg-gray-800 p-6 rounded-2xl shadow-lg border border-gray-700">.*?</section>)'
    r'(\n\s*</section>\n\s*</main>)',
    re.S
)

m = atlas_pattern.search(html)
if not m:
    raise SystemExit("atlas bottom-band target region not found")

atlas_block = m.group(1)
replacement = (
    '\n    <section id="phase61-atlas-band" class="space-y-4">\n'
    f'{atlas_block}\n'
    '    </section>'
    f'{m.group(2)}'
)

new_html = html[:m.start()] + replacement + html[m.end():]

new_html = re.sub(
    r'#phase61-workspace-grid\s*>\s*#atlas-status-card,\s*#phase61-workspace-grid\s*>\s*#phase61-atlas-band\s*\{[^}]*\}',
    '#phase61-atlas-band {\n        width: 100%;\n      }\n\n      #phase61-atlas-band #atlas-status-card {\n        width: 100%;\n      }',
    new_html,
    flags=re.S
)

if new_html == html:
    raise SystemExit("no atlas changes applied")

p.write_text(new_html, encoding="utf-8")
print("Moved Atlas into bottom band below workspace grid.")
PY

git diff -- public/dashboard.html || true
