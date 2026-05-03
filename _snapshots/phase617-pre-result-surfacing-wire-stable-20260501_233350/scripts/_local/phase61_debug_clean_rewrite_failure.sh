#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

set +e
scripts/_local/phase61_clean_rewrite_workspace_region.sh > /tmp/phase61_clean_rewrite.log 2>&1
rewrite_rc=$?

scripts/verify-dashboard-two-panel-structure.sh > /tmp/phase61_structure_verify.log 2>&1
verify_rc=$?

set -e

printf 'rewrite_rc=%s\n' "$rewrite_rc"
printf 'verify_rc=%s\n' "$verify_rc"

echo
echo '--- phase61_clean_rewrite log ---'
cat /tmp/phase61_clean_rewrite.log || true

echo
echo '--- phase61_structure_verify log ---'
cat /tmp/phase61_structure_verify.log || true

echo
echo '--- workspace id counts in public/dashboard.html ---'
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

echo
echo '--- first 260 lines around workspace region ---'
nl -ba public/dashboard.html | sed -n '200,460p'
