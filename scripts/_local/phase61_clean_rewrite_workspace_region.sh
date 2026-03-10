#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path
import shutil
import re

p = Path("public/dashboard.html")
if not p.exists():
    raise SystemExit("public/dashboard.html not found")

html = p.read_text(encoding="utf-8")
backup = p.with_suffix(".html.bak.phase61_clean_rewrite_v2")
shutil.copy2(p, backup)

main_match = re.search(r'(<main\b[^>]*>)(.*?)(</main>)', html, flags=re.S | re.I)
if not main_match:
    raise SystemExit("main region not found")

main_open, main_body, main_close = main_match.groups()

metrics_match = re.search(
    r'(<section\b[^>]*id=["\']metrics-row["\'][^>]*>.*?</section>)',
    main_body,
    flags=re.S | re.I
)
if not metrics_match:
    raise SystemExit("metrics row id anchor not found")

metrics_block = metrics_match.group(1)
metrics_end = metrics_match.end()

atlas_match = re.search(
    r'<section\b[^>]*(?:id=["\']atlas-subsystem-status-card["\']|id=["\']atlas-status-card["\'])[^>]*>.*?</section>',
    main_body,
    flags=re.S | re.I
)
if not atlas_match:
    raise SystemExit("atlas card not found")

atlas_html = atlas_match.group(0)
if 'id="atlas-subsystem-status-card"' not in atlas_html and "id='atlas-subsystem-status-card'" not in atlas_html:
    atlas_html = re.sub(
        r'^<section\b',
        '<section id="atlas-subsystem-status-card"',
        atlas_html,
        count=1,
        flags=re.S | re.I
    )

operator_match = re.search(
    r'<section\b[^>]*id=["\']phase61-operator-column["\'][^>]*>.*?</section>\s*</section>',
    main_body,
    flags=re.S | re.I
)
if not operator_match:
    raise SystemExit("operator column block not found")

operator_col = operator_match.group(0)
operator_card_match = re.search(
    r'<section\b[^>]*id=["\']operator-workspace-card["\'][^>]*>.*?</section>',
    operator_col,
    flags=re.S | re.I
)
if not operator_card_match:
    raise SystemExit("operator workspace card not found inside operator column")
operator_card = operator_card_match.group(0)

obs_col_match = re.search(
    r'<section\b[^>]*id=["\']phase61-(?:telemetry|observational)-column["\'][^>]*>.*?</section>\s*</section>',
    main_body,
    flags=re.S | re.I
)
if not obs_col_match:
    raise SystemExit("observational column block not found")

obs_col = obs_col_match.group(0)
obs_card_match = re.search(
    r'<section\b[^>]*id=["\']observational-workspace-card["\'][^>]*>.*?</section>',
    obs_col,
    flags=re.S | re.I
)
if not obs_card_match:
    raise SystemExit("observational workspace card not found inside observational column")
obs_card = obs_card_match.group(0)

new_workspace = f'''
<section id="phase61-workspace-shell" class="space-y-4">
  <div id="phase61-workspace-grid">
    {operator_card}
    {obs_card}
  </div>
  <section id="phase61-atlas-band">
    {atlas_html}
  </section>
</section>
'''.strip()

new_main_body = main_body[:metrics_end] + "\n\n" + new_workspace + "\n"

new_main = f"{main_open}{new_main_body}{main_close}"
new_html = html[:main_match.start()] + new_main + html[main_match.end():]

css = """
/* phase61 deterministic workspace rewrite v2 */
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

if "#phase61-workspace-grid" not in new_html:
    if "</style>" in new_html:
        new_html = new_html.replace("</style>", "\n" + css + "\n</style>", 1)
    elif "</head>" in new_html:
        new_html = new_html.replace("</head>", "<style>\n" + css + "\n</style>\n</head>", 1)
    else:
        raise SystemExit("no style/head target for css injection")

p.write_text(new_html, encoding="utf-8")
print("phase61 workspace region cleanly rewritten v2")
PY
