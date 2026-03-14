#!/usr/bin/env bash
set -euo pipefail

python3 <<'PY'
from pathlib import Path
import re

path = Path("public/dashboard.html")
text = path.read_text()
original = text

text = re.sub(
    r'\n\s*<script src="js/phase64_4_task_events_live_recovery\.js(?:\?[^"]*)?"></script>',
    '',
    text,
    flags=re.MULTILINE,
)

pattern = re.compile(
    r'(?P<tag>\s*<script src="js/phase61_recent_history_wire\.js(?:\?[^"]*)?"></script>\s*)',
    re.MULTILINE,
)

match = pattern.search(text)
if not match:
    raise SystemExit("phase61_recent_history_wire script tag not found in public/dashboard.html")

insertion = match.group("tag") + '  <script src="js/phase64_4_task_events_live_recovery.js?v=phase64_4_live_recovery_20260314b"></script>\n'
text = text[:match.start()] + insertion + text[match.end():]

if text == original:
    raise SystemExit("no changes applied to public/dashboard.html")

path.write_text(text)
print("patched public/dashboard.html")
PY
