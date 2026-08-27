#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== IMPLEMENT DECISIONS LIST COMPACT TITLE ==="
echo "EXPECTED_HEAD_PREFIX=22d60b70c"
echo "RECOVERY_POINT=DR_20260826_171804"
echo "MODE=EXECUTION_WITH_BOUNDED_AUTHORIZATION"
echo "PRODUCTION_CHANGE=PRESENTATION_ONLY"

CURRENT_HEAD="$(git rev-parse HEAD)"
if [[ "${CURRENT_HEAD}" != 22d60b70c* ]]; then
  echo "UNEXPECTED_HEAD=${CURRENT_HEAD}"
  exit 1
fi

python3 - << 'PY'
from pathlib import Path

tsx = Path("client/src/approvals/ApprovalsWorkspace.tsx")
source = tsx.read_text()

anchor = '''function readText(
  value: string | null,
  fallback = "Not recorded.",
): string {
  const normalized = value?.trim() ?? "";

  return normalized || fallback;
}
'''

replacement = '''function readText(
  value: string | null,
  fallback = "Not recorded.",
): string {
  const normalized = value?.trim() ?? "";

  return normalized || fallback;
}

export function deriveDecisionListTitle(value: string): string {
  const normalized = value.trim().replace(/\\\\s+/g, " ");

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

if source.count(anchor) != 1:
    raise SystemExit("READ_TEXT_ANCHOR_NOT_UNIQUE")

source = source.replace(anchor, replacement, 1)

old_heading = '''          {readText(
            request.evidence.expected_outcome,
            request.evidence.interpreted_objective,
          )}
'''

new_heading = '''          {deriveDecisionListTitle(
            readText(
              request.evidence.expected_outcome,
              request.evidence.interpreted_objective,
            ),
          )}
'''

if source.count(old_heading) != 1:
    raise SystemExit("DECISION_HEADING_ANCHOR_NOT_UNIQUE")

tsx.write_text(source.replace(old_heading, new_heading, 1))
PY

python3 - << 'PY'
from pathlib import Path

css = Path("client/src/approvals/approvals-workspace.css")
source = css.read_text()

anchor = '''.executive-inbox-item__heading strong {
  line-height: 1.25;
  overflow-wrap: anywhere;
}
'''

replacement = '''.executive-inbox-item__heading strong {
  display: -webkit-box;
  min-width: 0;
  overflow: hidden;
  line-height: 1.25;
  overflow-wrap: anywhere;
  -webkit-box-orient: vertical;
  -webkit-line-clamp: 2;
}
'''

if source.count(anchor) != 1:
    raise SystemExit("HEADING_STYLE_ANCHOR_NOT_UNIQUE")

css.write_text(source.replace(anchor, replacement, 1))
PY

cat > client/src/approvals/decisionListTitle.test.ts << 'TS'
import assert from "node:assert/strict";
import fs from "node:fs";
import test from "node:test";

import { deriveDecisionListTitle } from "./ApprovalsWorkspace";

test("short decision title remains unchanged after whitespace normalization", () => {
  assert.equal(
    deriveDecisionListTitle("  Review   Q3   launch plan  "),
    "Review Q3 launch plan",
  );
});

test("long decision title is shortened to a whole-word boundary", () => {
  const value =
    "Create one reviewable verification checklist confirming the Approvals interface displays request-specific package contents";

  const result = deriveDecisionListTitle(value);

  assert.equal(result.endsWith("…"), true);
  assert.equal(result.length <= 65, true);
  assert.equal(result, "Create one reviewable verification checklist confirming the…");
});

test("long unbroken decision title falls back to bounded character shortening", () => {
  const value = "a".repeat(80);

  assert.equal(
    deriveDecisionListTitle(value),
    `${"a".repeat(64)}…`,
  );
});

test("DecisionListItem applies compact title only to the heading", () => {
  const source = fs.readFileSync(
    "client/src/approvals/ApprovalsWorkspace.tsx",
    "utf8",
  );

  assert.match(
    source,
    /deriveDecisionListTitle\(\s*readText\(\s*request\.evidence\.expected_outcome,\s*request\.evidence\.interpreted_objective,/s,
  );

  assert.match(
    source,
    /executive-inbox-item__summary[\s\S]*readText\(request\.evidence\.interpreted_objective\)/,
  );

  assert.match(
    source,
    /<dt>Expected outcome<\/dt>\s*<dd>\{readText\(request\.evidence\.expected_outcome\)\}<\/dd>/s,
  );
});

test("decision heading is visually contained to two lines", () => {
  const source = fs.readFileSync(
    "client/src/approvals/approvals-workspace.css",
    "utf8",
  );

  assert.match(
    source,
    /\.executive-inbox-item__heading strong\s*\{[\s\S]*display:\s*-webkit-box;[\s\S]*overflow:\s*hidden;[\s\S]*-webkit-box-orient:\s*vertical;[\s\S]*-webkit-line-clamp:\s*2;/s,
  );
});
TS

echo
echo "=== FOCUSED COMPACT TITLE TESTS ==="
npx tsx --test client/src/approvals/decisionListTitle.test.ts

echo
echo "=== APPROVALS REGRESSION TESTS ==="
npx tsx --test \
  client/src/approvals/approvalRequestApi.test.ts \
  client/src/approvals/useApprovalRequests.test.ts 2>/dev/null || \
npx tsx --test client/src/approvals/approvalRequestApi.test.ts

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
  client/src/approvals/decisionListTitle.test.ts \
  implement-decisions-list-compact-title.sh

git commit -m "Keep decisions list titles compact"
git push
