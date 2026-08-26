#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

python3 - << 'PY'
from pathlib import Path

path = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = path.read_text()

old = '''                  requests.map((request, index) => (
                    <DecisionListItem
                      key={request.approval_request_id}
                      request={request}
                      index={index}
                      selected={
'''

new = '''                  requests.map((request) => (
                    <DecisionListItem
                      key={request.approval_request_id}
                      request={request}
                      selected={
'''

if old not in text:
    raise SystemExit("STOP: expected remaining DecisionListItem index binding not found")

text = text.replace(old, new, 1)
path.write_text(text)
PY

echo "=== VERIFY REMAINING INDEX PROP REMOVAL ==="
if rg -n 'index=\{index\}|requests\.map\(\(request, index\)' \
  client/src/approvals/ApprovalsWorkspace.tsx
then
  echo "REMAINING_INDEX_BINDING=YES"
  exit 1
fi
echo "REMAINING_INDEX_BINDING=NO"

(
  cd client
  npm run build
)

git diff --check

git add client/src/approvals/ApprovalsWorkspace.tsx
git commit -m "Remove remaining Approvals index binding"
git push
