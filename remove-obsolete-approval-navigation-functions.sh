#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 - << 'PY'
from pathlib import Path

path = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = path.read_text()

old = '''  function selectPrevious(): void {
    if (selectedIndex > 0) {
      setSelectedRequestId(
        requests[selectedIndex - 1].approval_request_id,
      );
    }
  }

  function selectNext(): void {
    if (
      selectedIndex >= 0 &&
      selectedIndex < requests.length - 1
    ) {
      setSelectedRequestId(
        requests[selectedIndex + 1].approval_request_id,
      );
    }
  }

'''

if old not in text:
    raise SystemExit("STOP: expected obsolete navigation functions not found")

text = text.replace(old, "", 1)
path.write_text(text)
PY

echo "=== VERIFY OBSOLETE NAVIGATION REMOVAL ==="
if rg -n 'function selectPrevious|function selectNext|ArtifactSwitcher' \
  client/src/approvals/ApprovalsWorkspace.tsx
then
  echo "OBSOLETE_NAVIGATION_REMOVAL=FAIL"
  exit 1
fi
echo "OBSOLETE_NAVIGATION_REMOVAL=PASS"

echo
echo "=== BUILD ==="
(
  cd client
  npm run build
)

git diff --check

git add client/src/approvals/ApprovalsWorkspace.tsx
git commit -m "Remove obsolete approval navigation"
git push
