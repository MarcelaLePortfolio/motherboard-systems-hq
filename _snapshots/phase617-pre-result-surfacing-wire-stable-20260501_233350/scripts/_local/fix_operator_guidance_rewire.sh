#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
TARGET="$ROOT/public/index.html"

python3 - <<'PY'
from pathlib import Path
import re

target = Path("public/index.html")
text = target.read_text()

# Remove failed Phase 489 bridge rewire script block
text = re.sub(
    r'\n<script id="phase489-h1-operator-guidance-rewire">.*?</script>\n',
    '\n',
    text,
    flags=re.S
)

# Ensure existing operator guidance SSE script is mounted once
script_tag = '  <script defer src="js/operatorGuidance.sse.js"></script>\n'
if 'js/operatorGuidance.sse.js' not in text:
    text = text.replace(
        '  <script defer src="js/task-completion.js"></script>\n',
        '  <script defer src="js/task-completion.js"></script>\n' + script_tag
    )

target.write_text(text)
PY
