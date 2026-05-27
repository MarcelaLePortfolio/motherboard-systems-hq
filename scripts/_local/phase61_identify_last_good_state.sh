#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

TARGET_FILES=(
  public/dashboard.html
  public/js/phase61_tabs_workspace.js
)

CANDIDATES=(
  "v61.0-observational-workspace-checkpoint"
  "0d466727"
  "1f86de05"
  "874af818"
  "e9d3b817"
)

echo "CURRENT_HEAD=$(git rev-parse --short HEAD)"
echo

for ref in "${CANDIDATES[@]}"; do
  if git rev-parse -q --verify "${ref}^{commit}" >/dev/null 2>&1; then
    echo "===== CANDIDATE: $ref ====="
    git --no-pager log -1 --oneline "$ref"
    echo
    echo "--- changed target files vs HEAD ---"
    git diff --name-only "$ref" -- "${TARGET_FILES[@]}" || true
    echo
    echo "--- dashboard diffstat vs HEAD ---"
    git diff --stat "$ref" -- "${TARGET_FILES[@]}" || true
    echo
    echo "--- key markers in dashboard at $ref ---"
    git show "$ref:public/dashboard.html" 2>/dev/null | python3 - <<'PY'
import sys
html = sys.stdin.read()
markers = [
    'Operator Workspace',
    'Observational Workspace',
    'Telemetry Workspace',
    'Recent Tasks',
    'Task History',
    'Task Events',
    'Atlas Subsystem Status',
    'phase61-workspace-shell',
    'phase61-workspace-grid',
]
for m in markers:
    print(f"{m}: {'YES' if m in html else 'NO'}")
PY
    echo
  fi
done

echo "===== FIRST BAD-STATE SEARCH ====="
git log --oneline --decorate -- public/dashboard.html public/js/phase61_tabs_workspace.js | sed -n '1,20p'
echo

echo "===== CURRENT FILE COUNTS ====="
python3 <<'PY'
from pathlib import Path
import re
html = Path("public/dashboard.html").read_text(encoding="utf-8")
tokens = [
    "phase61-workspace-shell",
    "phase61-workspace-grid",
    "operator-workspace-card",
    "observational-workspace-card",
    "phase61-atlas-band",
    "atlas-subsystem-status-card",
]
for token in tokens:
    count = len(re.findall(rf'id=["\\\']{re.escape(token)}["\\\']', html))
    print(f"{token}: {count}")
PY
