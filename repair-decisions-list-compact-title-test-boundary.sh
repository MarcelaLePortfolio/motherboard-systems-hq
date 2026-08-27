#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== REPAIR DECISIONS LIST COMPACT TITLE TEST BOUNDARY ==="
echo "EXPECTED_HEAD_PREFIX=22d60b70c"
echo "RECOVERY_POINT=DR_20260826_171804"
echo "IMPLEMENTATION_ATTEMPT=2"
echo "FAILURE_1=TEST_IMPORTED_APPROVALS_WORKSPACE_AND_NODE_COULD_NOT_LOAD_CSS"
echo "REPAIR=EXTRACT_PRESENTATION_HELPER_TO_CSS_FREE_MODULE"
echo "CONTRACT_CHANGE=NO"
echo "PRODUCTION_SCOPE_EXPANSION=NO"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 22d60b70c* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

cat > client/src/approvals/decisionListTitle.ts << 'TS'
export function deriveDecisionListTitle(value: string): string {
  const normalized = value.trim().replace(/\s+/g, " ");

  if (normalized.length <= 64) {
    return normalized;
  }

  const bounded = normalized.slice(0, 64);
  const finalWhitespaceIndex = bounded.lastIndexOf(" ");
  const prefix =
    finalWhitespaceIndex > 0
      ? bounded.slice(0, finalWhitespaceIndex)
      : bounded;

  return `${prefix}…`;
}
TS

python3 - << 'PY'
from pathlib import Path

tsx = Path("client/src/approvals/ApprovalsWorkspace.tsx")
source = tsx.read_text()

helper_block = '''export function deriveDecisionListTitle(value: string): string {
  const normalized = value.trim().replace(/\\s+/g, " ");

  if (normalized.length <= 64) {
    return normalized;
  }

  const bounded = normalized.slice(0, 64);
  const finalWhitespaceIndex = bounded.lastIndexOf(" ");
  const prefix =
    finalWhitespaceIndex > 0
      ? bounded.slice(0, finalWhitespaceIndex)
      : bounded;

  return `${prefix}…`;
}

'''

if source.count(helper_block) != 1:
    raise SystemExit(f"HELPER_BLOCK_COUNT={source.count(helper_block)}")

source = source.replace(helper_block, "", 1)

import_anchor = '''import { useApprovalRequests } from "./useApprovalRequests";

import "./approvals-workspace.css";
'''

import_replacement = '''import { deriveDecisionListTitle } from "./decisionListTitle";
import { useApprovalRequests } from "./useApprovalRequests";

import "./approvals-workspace.css";
'''

if source.count(import_anchor) != 1:
    raise SystemExit(f"IMPORT_ANCHOR_COUNT={source.count(import_anchor)}")

tsx.write_text(source.replace(import_anchor, import_replacement, 1))

test_path = Path("client/src/approvals/decisionListTitle.test.ts")
test_source = test_path.read_text()

old_import = '''import { deriveDecisionListTitle } from "./ApprovalsWorkspace";
'''
new_import = '''import { deriveDecisionListTitle } from "./decisionListTitle";
'''

if test_source.count(old_import) != 1:
    raise SystemExit(f"TEST_IMPORT_COUNT={test_source.count(old_import)}")

test_path.write_text(test_source.replace(old_import, new_import, 1))
PY

echo
echo "=== VERIFY PRESENTATION BOUNDARY ==="
rg -n -C 5 \
  'deriveDecisionListTitle|expected_outcome|executive-inbox-item__heading strong' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/decisionListTitle.ts \
  client/src/approvals/decisionListTitle.test.ts \
  client/src/approvals/approvals-workspace.css

echo
echo "=== FOCUSED COMPACT TITLE TESTS ==="
npx tsx --test \
  client/src/approvals/decisionListTitle.test.ts

echo
echo "=== APPROVALS API REGRESSION ==="
npx tsx --test \
  client/src/approvals/approvalRequestApi.test.ts

echo
echo "=== TYPECHECK ==="
npm run check

echo
echo "=== BUILD ==="
npm run build

echo
echo "=== DIFF CHECK ==="
git diff --check

git add \
  client/src/approvals/ApprovalsWorkspace.tsx \
  client/src/approvals/approvals-workspace.css \
  client/src/approvals/decisionListTitle.ts \
  client/src/approvals/decisionListTitle.test.ts \
  implement-decisions-list-compact-title.sh \
  repair-decisions-list-compact-title-test-boundary.sh

git commit -m "Keep decisions list titles compact"
git push
