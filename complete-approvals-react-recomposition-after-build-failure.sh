#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 - << 'PY'
from pathlib import Path

path = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = path.read_text()

old = '''          {selectedRequestId ? (
            <ArtifactSwitcher
              requests={requests}
              selectedRequestId={selectedRequestId}
              onSelect={setSelectedRequestId}
              onPrevious={selectPrevious}
              onNext={selectNext}
              previousDisabled={selectedIndex <= 0}
              nextDisabled={
                selectedIndex < 0 ||
                selectedIndex >= requests.length - 1
              }
            />
          ) : null}

'''

if old not in text:
    raise SystemExit("STOP: expected remaining ArtifactSwitcher render block not found")

text = text.replace(old, "", 1)
path.write_text(text)
PY

echo "=== VERIFY ARTIFACT SWITCHER REMOVAL ==="
if rg -n 'function ArtifactSwitcher|<ArtifactSwitcher' \
  client/src/approvals/ApprovalsWorkspace.tsx
then
  echo "ARTIFACT_SWITCHER_REMOVAL=FAIL"
  exit 1
fi
echo "ARTIFACT_SWITCHER_REMOVAL=PASS"

echo
echo "=== BUILD ==="
(
  cd client
  npm run build
)

git diff --check

git add client/src/approvals/ApprovalsWorkspace.tsx
git commit -m "Complete Approvals React recomposition"
git push

echo
echo "REACT_RECOMPOSITION=COMMITTED"
echo "CLIENT_BUILD=PASS"
echo "NEXT_ACTION=LIVE_VISUAL_REVIEW_BEFORE_REMOVING_PACKAGES_TAB"
