#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

python3 <<'PY'
from pathlib import Path

path = Path("public/dashboard.html")
text = path.read_text()

needle = '<script src="bundle.js"></script>'
script_tag = '  <script src="js/phase61_recent_history_wire.js"></script>\n'

if 'js/phase61_recent_history_wire.js' in text:
    print("phase61_recent_history_wire.js already present")
else:
    if needle not in text:
        raise SystemExit("bundle.js script tag not found in public/dashboard.html")
    text = text.replace(needle, script_tag + '  ' + needle, 1)
    path.write_text(text)
    print("restored phase61_recent_history_wire.js script tag")
PY
