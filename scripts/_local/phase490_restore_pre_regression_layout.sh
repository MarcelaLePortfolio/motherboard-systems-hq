#!/usr/bin/env bash
set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
BASE_COMMIT="3ebbb226"

git restore --source="$BASE_COMMIT" -- public/index.html

rm -f public/js/phase490_measured_panel_height_sync.js
rm -f public/js/phase490_height_diagnostic_overlay.js

python3 - <<'PY'
from pathlib import Path

p = Path("public/index.html")
text = p.read_text()

for tag in [
    '  <script defer src="js/phase490_measured_panel_height_sync.js"></script>\n',
    '  <script defer src="js/phase490_height_diagnostic_overlay.js"></script>\n',
]:
    text = text.replace(tag, "")

p.write_text(text)
print("Restored public/index.html to pre-Phase-490 layout state and removed residual Phase 490 mounts.")
PY
