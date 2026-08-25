#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== FIX OPERATIONAL PACKAGE AUTHORITY GAP INSPECTION ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current
git status --short

echo
echo "=== FAILURE CLASSIFICATION ==="
echo "FAILED_HYPOTHESIS=NO"
echo "REPOSITORY_DEFECT_ESTABLISHED=NO"
echo "INSPECTION_SCRIPT_DEFECT=YES"
echo "DEFECT=RG_NO_MATCH_EXIT_1_TERMINATED_SCRIPT_UNDER_SET_E_PIPEFAIL"
echo "FAILURE_POINT=SEARCH_FOR_AUTHORITATIVE_PACKAGE_NOMINATION_PERSISTENCE"
echo "EVIDENCE_BEFORE_FAILURE_REMAINS_VALID=YES"
echo "PRODUCTION_CHANGE=NONE"
echo "IMPLEMENTATION_AUTHORIZED=NO"

python3 <<'PY'
from pathlib import Path

path = Path("inspect-operational-package-authority-gap.sh")
text = path.read_text()

old = """  db server drizzle client/src docs/governance \\
  2>/dev/null | head -n 4200
"""

new = """  db server drizzle client/src docs/governance \\
  2>/dev/null | head -n 4200 || true
"""

if old not in text:
    raise SystemExit(
        "Expected authoritative nomination search pipeline not found; refusing speculative edit."
    )

text = text.replace(old, new, 1)

old2 = """  2>/dev/null | head -n 3000
"""

new2 = """  2>/dev/null | head -n 3000 || true
"""

if old2 not in text:
    raise SystemExit(
        "Expected delegation semantics search pipeline not found; refusing speculative edit."
    )

text = text.replace(old2, new2, 1)
path.write_text(text)
PY

echo
echo "=== VERIFY REPAIR IS INSPECTION-ONLY ==="
git diff -- inspect-operational-package-authority-gap.sh

echo
echo "=== VERIFY NO UNEXPECTED CHANGES ==="
UNEXPECTED="$(
  git status --short \
    | grep -vE 'inspect-operational-package-authority-gap\.sh$|fix-operational-package-authority-gap-inspection\.sh$' \
    || true
)"
if [[ -n "$UNEXPECTED" ]]; then
  echo "ERROR=UNEXPECTED_WORKTREE_CHANGES"
  printf '%s\n' "$UNEXPECTED"
  exit 1
fi

echo
echo "=== COMMIT REPAIRED INSPECTION ==="
git add inspect-operational-package-authority-gap.sh
git commit -m "Fix operational Package authority gap inspection"
git push

echo
echo "=== RERUN COMPLETE INSPECTION ==="
chmod +x inspect-operational-package-authority-gap.sh
./inspect-operational-package-authority-gap.sh

echo
echo "=== FINAL WORKTREE ==="
git status --short
