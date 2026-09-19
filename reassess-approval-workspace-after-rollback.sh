#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="b01033994"
PRE_HEAD="$(git rev-parse HEAD)"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

printf '\n=== POST-ROLLBACK BASELINE ===\n'
echo "MODE=READ_ONLY"
echo "THREE_HYPOTHESIS_RULE_SATISFIED=YES"
echo "PRODUCT_FIX_COMPLETE=NO"
echo "RUNTIME_VALIDATION_READY=NO"

printf '\n=== EXACT WORKSPACE SOURCE WITH INVISIBLE CHARACTERS ===\n'
sed -n '188,198l' client/src/approvals/ApprovalsWorkspace.tsx

printf '\n=== EXACT WORKSPACE SOURCE AS BYTES ===\n'
python3 <<'PY'
from pathlib import Path

p = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = p.read_text()
needle = "approveCanonicalPackage"
idx = text.find(needle)

if idx < 0:
    raise SystemExit("approveCanonicalPackage call not found")

start = max(0, text.rfind("\n", 0, idx - 120))
end = text.find("\n", idx + 220)
if end < 0:
    end = len(text)

snippet = text[start:end]
print(repr(snippet))
print("CALLSITE_START_OFFSET=", idx)
PY

printf '\n=== STRUCTURAL CALLSITE CLASSIFICATION ===\n'
python3 <<'PY'
from pathlib import Path
import re

text = Path("client/src/approvals/ApprovalsWorkspace.tsx").read_text()

pattern = re.compile(
    r'await\s+approveCanonicalPackage\s*\(\s*'
    r'request\.draft_package_id\s*,?\s*'
    r'\)\s*;'
)

matches = list(pattern.finditer(text))

print(f"STRUCTURAL_MATCH_COUNT={len(matches)}")

for i, match in enumerate(matches, 1):
    print(f"MATCH_{i}={match.group(0)!r}")

if len(matches) != 1:
    raise SystemExit("Expected exactly one structural approve callsite")
PY

printf '\n=== VERIFY PARTIAL IMPLEMENTATION STILL PRESENT ===\n'
grep -q 'createDraftRevisionForApprovalReview' \
  db/approval-request-model-assembler.ts
grep -q 'draft_revision_id: revision.draft_revision_id' \
  db/approval-request-model-assembler.ts
grep -q 'draft_revision_id: string;' \
  client/src/approvals/approvalRequestApi.ts
grep -q 'draft_revision_id: normalizedDraftRevisionId' \
  client/src/approvals/approvalRequestApi.ts

printf '\n=== VERIFY PROTECTED BOUNDARIES UNCHANGED ===\n'
git diff --exit-code -- \
  client/src/approvals/ApprovalsWorkspace.tsx \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  db/matilda-draft-revision-runtime.ts \
  server/execution \
  server/operational \
  db/governance-execution-approvals.ts \
  db/governance-execution-scopes.ts \
  db/governance-execution-reconciliation-persistence.ts

test "$(git rev-parse HEAD)" = "$PRE_HEAD"

printf '\n=== STOPPING POINT ===\n'
echo "REASSESSMENT_COMPLETE=YES"
echo "NEW_APPROACH=STRUCTURAL_REGEX_REPLACEMENT_NOT_EXACT_MULTILINE_TEXT_ANCHOR"
echo "MUTATION_EXECUTED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGE=NO"
echo "NEXT_ACTION=ONLY_IF_STRUCTURAL_MATCH_COUNT_IS_ONE_PREPARE_FRESH_IMPLEMENTATION_AUTHORIZATION_GATE"
echo "CLEAR_STOPPING_POINT=YES"
