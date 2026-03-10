#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path
import re

p = Path("public/dashboard.html")
html = p.read_text(encoding="utf-8")
original = html

css_block = """
#phase61-workspace-grid > #atlas-status-card,
#phase61-workspace-grid > #phase61-atlas-band {
  grid-column: 1 / -1;
  width: 100%;
}
""".strip()

if css_block in html:
    print("atlas full-width css already present")
    raise SystemExit(0)

style_match = re.search(r'<style[^>]*id=["\']phase61-layout-polish["\'][^>]*>(.*?)</style>', html, flags=re.S | re.I)
if style_match:
    inner = style_match.group(1).rstrip() + "\n\n      " + css_block + "\n    "
    html = html[:style_match.start(1)] + inner + html[style_match.end(1):]
else:
    html = html.replace("</head>", f"<style id=\"phase61-atlas-full-width-only\">\n{css_block}\n</style>\n</head>", 1)

if html == original:
    raise SystemExit("no changes applied")

p.write_text(html, encoding="utf-8")
print("Applied CSS-only Atlas full-width change.")
PY

git diff -- public/dashboard.html
