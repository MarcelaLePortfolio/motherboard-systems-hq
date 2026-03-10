#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
cd "$ROOT_DIR"

TARGET_HTML="public/dashboard.html"
TARGET_ENTRY="public/js/dashboard-bundle-entry.js"

scripts/verify-dashboard-layout-contract.sh "$TARGET_HTML"

cp "$TARGET_ENTRY" "${TARGET_ENTRY}.bak.phase61_5_2"

python3 - << 'PY'
from pathlib import Path

path = Path("public/js/dashboard-bundle-entry.js")
text = path.read_text()

needle = 'import "./matilda-chat-console.js";\n'
insert = 'import "./matilda-chat-console.js";\nimport "./dashboard-delegation.js";\n'

if 'import "./dashboard-delegation.js";' not in text:
    if needle in text:
        text = text.replace(needle, insert, 1)
    else:
        raise SystemExit("could not find matilda chat import anchor in dashboard-bundle-entry.js")

path.write_text(text)
PY

scripts/verify-dashboard-layout-contract.sh "$TARGET_HTML"
