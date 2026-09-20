#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="d92f6a013"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"
test -z "$(git diff --cached --name-only)"

TARGET="client/src/approvals/ApprovalsWorkspace.tsx"

printf '\n=== AUTHORIZED REPAIR BOUNDARY ===\n'
echo "AUTHORIZED_FILE=$TARGET"
echo "AUTHORIZED_REMOVAL=feedbackReady_STATE_DECLARATION_AND_SIX_FALSE_ONLY_SETTERS"
echo "APPROVAL_HANDOFF_SEMANTICS_CHANGE_AUTHORIZED=NO"
echo "REQUEST_CHANGES_SEMANTICS_CHANGE_AUTHORIZED=NO"
echo "CANONICAL_BOUNDARY_CHANGE_AUTHORIZED=NO"
echo "DELEGATION_CHANGE_AUTHORIZED=NO"
echo "VALIDATION_CHANGE_AUTHORIZED=NO"
echo "ENVELOPE_CHANGE_AUTHORIZED=NO"
echo "EXECUTION_CHANGE_AUTHORIZED=NO"
echo "GOVERNANCE_CHANGE_AUTHORIZED=NO"
echo "AUTHORITY_CHANGE_AUTHORIZED=NO"

printf '\n=== VERIFY PRECONDITION ===\n'
python3 <<'PY'
from pathlib import Path
import re

path = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = path.read_text()

declarations = re.findall(
    r'^[ \t]*const\s*\[\s*feedbackReady\s*,\s*setFeedbackReady\s*\]\s*=\s*useState\(false\);\s*$',
    text,
    flags=re.MULTILINE,
)

setters = re.findall(
    r'^[ \t]*setFeedbackReady\(false\);\s*$',
    text,
    flags=re.MULTILINE,
)

if len(declarations) != 1:
    raise SystemExit(
        f"Expected exactly one feedbackReady declaration; found {len(declarations)}"
    )

if len(setters) != 6:
    raise SystemExit(
        f"Expected exactly six false-only setter calls; found {len(setters)}"
    )

print("PRECONDITION_DECLARATION_COUNT=1")
print("PRECONDITION_FALSE_SETTER_COUNT=6")
PY

printf '\n=== EXECUTE NARROW DEAD-STATE REMOVAL ===\n'
python3 <<'PY'
from pathlib import Path
import re

path = Path("client/src/approvals/ApprovalsWorkspace.tsx")
text = path.read_text()

text, declaration_count = re.subn(
    r'^[ \t]*const\s*\[\s*feedbackReady\s*,\s*setFeedbackReady\s*\]\s*=\s*useState\(false\);\s*\n',
    "",
    text,
    count=1,
    flags=re.MULTILINE,
)

text, setter_count = re.subn(
    r'^[ \t]*setFeedbackReady\(false\);\s*\n',
    "",
    text,
    flags=re.MULTILINE,
)

if declaration_count != 1:
    raise SystemExit(
        f"Declaration removal count was {declaration_count}, expected 1"
    )

if setter_count != 6:
    raise SystemExit(
        f"Setter removal count was {setter_count}, expected 6"
    )

path.write_text(text)

print("FEEDBACKREADY_DECLARATION_REMOVED=1")
print("FEEDBACKREADY_FALSE_SETTERS_REMOVED=6")
PY

printf '\n=== VERIFY EXACT MUTATION ===\n'
if grep -n -E '\bfeedbackReady\b|\bsetFeedbackReady\b' "$TARGET"; then
  echo "FEEDBACKREADY_RESIDUE=YES"
  exit 1
fi

git diff -- "$TARGET"

CHANGED="$(git diff --name-only -- "$TARGET")"
test "$CHANGED" = "$TARGET"

printf '\n=== TARGETED APPROVAL TESTS ===\n'
npx tsx --test \
  db/approval-request-model-assembler.test.ts \
  routes/api-approval-request.test.ts

printf '\n=== SERVER BUILD ===\n'
npm run build

printf '\n=== CLIENT BUILD ===\n'
npm --prefix client run build

printf '\n=== VERIFY PROTECTED BOUNDARIES ===\n'
git diff --exit-code -- \
  db/approval-request-model-assembler.ts \
  client/src/approvals/approvalRequestApi.ts \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-canonical-package-runtime.ts \
  server/routes/matilda-canonical-package-route.ts \
  server/execution \
  server/operational \
  db/governance-execution-approvals.ts \
  db/governance-execution-scopes.ts \
  db/governance-execution-reconciliation-persistence.ts

printf '\n=== FINAL CLASSIFICATION ===\n'
echo "FEEDBACKREADY_CLIENT_BUILD_REPAIR=IMPLEMENTED"
echo "FEEDBACKREADY_DECLARATION_REMOVED=YES"
echo "FEEDBACKREADY_FALSE_ONLY_SETTERS_REMOVED=6"
echo "TARGETED_APPROVAL_TESTS=PASS"
echo "SERVER_BUILD=PASS"
echo "CLIENT_BUILD=PASS"
echo "APPROVAL_HANDOFF_SEMANTICS_CHANGED=NO"
echo "REQUEST_CHANGES_SEMANTICS_CHANGED=NO"
echo "CANONICAL_BOUNDARY_CHANGED=NO"
echo "DELEGATION_CHANGED=NO"
echo "VALIDATION_CHANGED=NO"
echo "ENVELOPE_CHANGED=NO"
echo "EXECUTION_CHANGED=NO"
echo "GOVERNANCE_CHANGED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=RUNTIME_VALIDATE_NATURAL_MATILDA_APPROVAL_FLOW"
echo "CLEAR_STOPPING_POINT=YES"
