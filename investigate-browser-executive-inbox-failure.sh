#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"

echo "============================================================"
echo " BROWSER CONFIRMATION FAILURE — READ-ONLY INVESTIGATION"
echo "============================================================"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

echo "LOCAL_HEAD=$(git rev-parse --short=9 HEAD)"
echo "REMOTE_HEAD=$(git rev-parse --short=9 "origin/$BRANCH")"
echo "PRODUCT_MUTATION=NO"
echo "DATABASE_MUTATION=NO"
echo "AUTHORITY_CHANGE=NO"

echo
echo "=== A. IDENTIFY ACTIVE SERVER LISTENERS ==="
for PORT in 3000 3001 5173 5174; do
  echo "--- PORT $PORT ---"
  lsof -nP -iTCP:"$PORT" -sTCP:LISTEN || true
done

echo
echo "=== B. TEST BROWSER-LIKELY BACKEND ON PORT 3000 ==="
for PATHNAME in \
  "/api/approval-requests?project_id=hq" \
  "/api/canonical-packages?project_id=hq"
do
  echo "--- http://127.0.0.1:3000${PATHNAME} ---"
  curl -sS -i "http://127.0.0.1:3000${PATHNAME}" | head -80 || true
done

echo
echo "=== C. TEST VALIDATED ISOLATED PORT IF PRESENT ==="
if lsof -nP -iTCP:3001 -sTCP:LISTEN >/dev/null 2>&1; then
  for PATHNAME in \
    "/api/approval-requests?project_id=hq" \
    "/api/canonical-packages?project_id=hq"
  do
    echo "--- http://127.0.0.1:3001${PATHNAME} ---"
    curl -sS -i "http://127.0.0.1:3001${PATHNAME}" | head -80 || true
  done
else
  echo "PORT_3001_LISTENER=ABSENT"
fi

echo
echo "=== D. INSPECT CLIENT API REQUEST TARGETS ==="
sed -n '1,300p' client/src/approvals/approvalRequestApi.ts
echo
sed -n '1,300p' client/src/approvals/canonicalPackageReadApi.ts

echo
echo "=== E. INSPECT PROVIDER FAILURE COUPLING ==="
sed -n '1,280p' client/src/approvals/ApprovalRequestProvider.tsx

echo
echo "=== F. INSPECT SERVER ROUTE MOUNTS ==="
grep -n -E \
  'approval-requests|canonical-packages|createCanonicalPackageReadRouter|createApproval|app\.use|router' \
  server/index.ts \
  | head -260 || true

echo
echo "============================================================"
echo " BROWSER FAILURE INVESTIGATION — STOP HERE"
echo "============================================================"
echo "BROWSER_CONFIRMATION=FAILED"
echo "EXECUTIVE_INBOX_LOAD=FAILED"
echo "RUNTIME_VALIDATION_PREVIOUSLY_PASSED=YES"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "CORRIDOR_CLOSED=NO"
echo "NEXT_ACTION=CLASSIFY_BROWSER_RUNTIME_VS_API_FAILURE_FROM_OUTPUT"
echo "CLEAR_STOPPING_POINT=YES"
