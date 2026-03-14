#!/usr/bin/env bash
set -euo pipefail

python3 <<'PY'
from pathlib import Path

path = Path("public/dashboard.html")
text = path.read_text()
original = text

script_tag = '  <script src="js/phase64_4_task_events_live_recovery.js"></script>\n'
anchor = '  <script src="js/phase61_recent_history_wire.js?v=phase64_3_minimal_fix_20260314a"></script>\n'

if script_tag in text:
    print("no changes needed for public/dashboard.html")
    raise SystemExit(0)

if anchor not in text:
    fallback = '  <script src="js/phase61_recent_history_wire.js"></script>\n'
    if fallback not in text:
        raise SystemExit("phase61_recent_history_wire script tag not found in public/dashboard.html")
    text = text.replace(fallback, fallback + script_tag, 1)
else:
    text = text.replace(anchor, anchor + script_tag, 1)

if text == original:
    raise SystemExit("no changes applied to public/dashboard.html")

path.write_text(text)
print("patched public/dashboard.html")
PY
