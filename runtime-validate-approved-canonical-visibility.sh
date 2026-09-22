#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="3a9ec6f9b"
PROJECT_ID="hq"
PORT="3001"
LOG_FILE="/tmp/canonical-visibility-runtime-validation.log"
CANONICAL_JSON="/tmp/canonical-packages-runtime.json"
APPROVAL_JSON="/tmp/approval-requests-runtime.json"

echo "============================================================"
echo " RUNTIME VALIDATION — APPROVED CANONICAL VISIBILITY"
echo "============================================================"

git fetch origin "$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$EXPECTED_HEAD"

echo "BASELINE_VERIFIED=YES"
echo "MODE=VALIDATION_ONLY"
echo "PROJECT_ID=$PROJECT_ID"
echo "DATABASE_MUTATION=NO"
echo "AUTHORITY_CHANGE=NO"

npm run build
npm --prefix client run build

if lsof -nP -iTCP:"$PORT" -sTCP:LISTEN >/dev/null 2>&1; then
  echo "STOP=PORT_${PORT}_ALREADY_IN_USE"
  lsof -nP -iTCP:"$PORT" -sTCP:LISTEN
  exit 1
fi

PORT="$PORT" node dist/server/index.js >"$LOG_FILE" 2>&1 &
SERVER_PID=$!

cleanup() {
  kill "$SERVER_PID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

for _ in $(seq 1 30); do
  if curl -fsS \
    "http://127.0.0.1:${PORT}/api/canonical-packages?project_id=${PROJECT_ID}" \
    >"$CANONICAL_JSON" 2>/dev/null
  then
    break
  fi

  if ! kill -0 "$SERVER_PID" >/dev/null 2>&1; then
    echo "STOP=SERVER_EXITED_DURING_STARTUP"
    cat "$LOG_FILE"
    exit 1
  fi

  sleep 0.25
done

test -s "$CANONICAL_JSON" || {
  echo "STOP=CANONICAL_READ_ENDPOINT_UNREACHABLE"
  cat "$LOG_FILE"
  exit 1
}

curl -fsS \
  "http://127.0.0.1:${PORT}/api/approval-requests?project_id=${PROJECT_ID}" \
  >"$APPROVAL_JSON"

python3 << 'PY'
import json
from pathlib import Path

canonical = json.loads(
    Path("/tmp/canonical-packages-runtime.json").read_text()
)
approvals = json.loads(
    Path("/tmp/approval-requests-runtime.json").read_text()
)

if canonical.get("project_id") != "hq":
    raise SystemExit(
        f"STOP=CANONICAL_PROJECT_SCOPE_MISMATCH:{canonical.get('project_id')}"
    )

packages = canonical.get("packages")
if not isinstance(packages, list):
    raise SystemExit("STOP=CANONICAL_PACKAGES_NOT_A_LIST")

approved = [
    package
    for package in packages
    if package.get("status") == "canonical_approved"
]

if not approved:
    raise SystemExit("STOP=NO_APPROVED_CANONICAL_PACKAGE_RETURNED")

requests = approvals.get("requests")
if not isinstance(requests, list):
    raise SystemExit("STOP=APPROVAL_REQUESTS_NOT_A_LIST")

approved_draft_ids = {
    package.get("draft_package_id")
    for package in approved
    if package.get("draft_package_id")
}

pending_draft_ids = {
    request.get("draft_package_id")
    for request in requests
    if request.get("draft_package_id")
}

overlap = approved_draft_ids & pending_draft_ids

if overlap:
    raise SystemExit(
        "STOP=APPROVED_DRAFT_STILL_PRESENT_AS_PENDING:"
        + ",".join(sorted(overlap))
    )

print("CANONICAL_API_PROJECT_SCOPE=VALIDATED")
print(f"APPROVED_CANONICAL_PACKAGE_COUNT={len(approved)}")
print(f"PENDING_APPROVAL_REQUEST_COUNT={len(requests)}")
print("APPROVED_AND_PENDING_DISTINCT=YES")

for package in approved:
    print(
        "APPROVED_CANONICAL="
        f"{package.get('package_id')}:"
        f"{package.get('package_version')}:"
        f"{package.get('draft_package_id')}"
    )
PY

grep -q 'fetchCanonicalPackages' \
  client/src/approvals/ApprovalRequestProvider.tsx

grep -q '<DecisionBadge>Approved</DecisionBadge>' \
  client/src/approvals/ApprovalsWorkspace.tsx

grep -q 'function ApprovedCanonicalPackageBriefing' \
  client/src/approvals/ApprovalsWorkspace.tsx

python3 << 'PY'
from pathlib import Path

text = Path(
    "client/src/approvals/ApprovalsWorkspace.tsx"
).read_text()

start = text.index(
    "function ApprovedCanonicalPackageBriefing"
)
end = text.index(
    "export default function ApprovalsWorkspace()",
    start,
)

approved_detail = text[start:end]

for forbidden in (
    "approveCanonicalPackage(",
    "requestChanges(",
    "Request Changes",
):
    if forbidden in approved_detail:
        raise SystemExit(
            "STOP=APPROVED_PRESENTATION_EXPOSES_ACTION:"
            + forbidden
        )

print("APPROVED_PRESENTATION_READ_ONLY=YES")
print("APPROVED_APPROVE_ACTION=NO")
print("APPROVED_REQUEST_CHANGES_ACTION=NO")
PY

echo
echo "============================================================"
echo " RUNTIME VALIDATION PASSED"
echo "============================================================"
echo "CANONICAL_READ_ENDPOINT=VALIDATED"
echo "APPROVED_CANONICAL_VISIBILITY=VALIDATED"
echo "PENDING_AND_APPROVED_DISTINCT=YES"
echo "APPROVED_PRESENTATION_READ_ONLY=YES"
echo "PACKAGES_TAB_RESTORED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=MANUAL_BROWSER_CONFIRMATION"
echo "DO_NOT_START_NEW_DOGFOOD_CONVERSATION=YES"
echo "CLEAR_STOPPING_POINT=YES"
