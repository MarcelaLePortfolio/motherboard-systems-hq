
#!/usr/bin/env bash

set -euo pipefail

python3 - << 'PY'

from pathlib import Path

import re

dashboard = Path("public/dashboard.html")

index = Path("public/index.html")

d = dashboard.read_text()

i = index.read_text()

style_ids = [

    "matilda-chat-typography-polish",

    "phase487-layout-refinement",

    "phase489-unified-panel-heights",

    "phase490-evidence-based-height-fix",

    "phase489-task-activity-scroll",

    "phase489-recent-tasks-scroll",

    "phase488-h3a-spacing-only",

    "phase488-h1-top-row-balance",

    "phase488-h2-tab-polish",

    "phase488-h2-unified-tab-color",

    "phase488-h4-micro-visual-hierarchy",

]

def extract_style(source, style_id):

    pattern = re.compile(

        rf'<style id="{re.escape(style_id)}"[\s\S]*?</style>',

        re.MULTILINE,

    )

    match = pattern.search(source)

    return match.group(0) if match else None

missing = []

blocks = []

for style_id in style_ids:

    if f'<style id="{style_id}"' in d:

        continue

    block = extract_style(i, style_id)

    if not block:

        missing.append(style_id)

        continue

    blocks.append(block.strip())

if missing:

    raise SystemExit("Missing style blocks in public/index.html: " + ", ".join(missing))

if blocks:

    insertion = "\n\n  <!-- restored served dashboard inline layout styles -->\n  " + "\n\n  ".join(blocks) + "\n"

    d = d.replace("</head>", insertion + "\n</head>", 1)

dashboard.write_text(d)

PY

grep -nE '<style id="phase487-layout-refinement"|<style id="phase489-unified-panel-heights"|<style id="phase490-evidence-based-height-fix"|<style id="phase488-h4-micro-visual-hierarchy"' public/dashboard.html

git diff -- public/dashboard.html

git add public/dashboard.html restore-served-dashboard-inline-layout-styles.sh

git commit -m "Restore served dashboard inline layout styles"

git push

