#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 - << 'PY'
from pathlib import Path

path = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = path.read_text()

start = text.index("function artifactLabel(")
end = text.index("function DecisionBadge(")

text = text[:start] + text[end:]

text = text.replace(
'''function DecisionListItem({
  request,
  index,
  selected,
  onSelect,
}: {
  request: ApprovalRequestReadModel;
  index: number;
  selected: boolean;
  onSelect(): void;
}) {
''',
'''function DecisionListItem({
  request,
  selected,
  onSelect,
}: {
  request: ApprovalRequestReadModel;
  selected: boolean;
  onSelect(): void;
}) {
'''
)

text = text.replace(
'''                  <DecisionListItem
                    key={request.approval_request_id}
                    request={request}
                    index={index}
                    selected={
                      request.approval_request_id === selectedRequestId
                    }
''',
'''                  <DecisionListItem
                    key={request.approval_request_id}
                    request={request}
                    selected={
                      request.approval_request_id === selectedRequestId
                    }
'''
)

path.write_text(text)
PY

echo "=== VERIFY OBSOLETE TITLE HELPERS REMOVED ==="
if rg -n 'function artifactLabel|index,' client/src/approvals/ApprovalsWorkspace.tsx
then
  echo "OBSOLETE_HELPER_REMOVAL=FAIL"
  exit 1
fi
echo "OBSOLETE_HELPER_REMOVAL=PASS"

(
  cd client
  npm run build
)

git diff --check

git add client/src/approvals/ApprovalsWorkspace.tsx
git commit -m "Remove obsolete Approvals title helper"
git push
