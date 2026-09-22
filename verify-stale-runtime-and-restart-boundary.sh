#!/usr/bin/env bash
set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"

echo "============================================================"
echo " BROWSER FAILURE — STALE RUNTIME CLASSIFICATION"
echo "============================================================"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"

echo "LOCAL_HEAD=$(git rev-parse --short=9 HEAD)"
echo "REMOTE_HEAD=$(git rev-parse --short=9 "origin/$BRANCH")"

echo
echo "=== A. VERIFY CURRENT SOURCE CONTAINS CANONICAL ROUTE ==="
grep -n -E \
  'canonicalPackageReadRouter|createCanonicalPackageReadRouter|api-canonical-package-read' \
  server/index.ts

echo
echo "=== B. VERIFY CURRENT COMPILED SERVER CONTAINS ROUTE ==="
npm run build

grep -n -E \
  'canonicalPackageReadRouter|createCanonicalPackageReadRouter|api-canonical-package-read' \
  dist/server/index.js || {
    echo "STOP=CURRENT_COMPILED_SERVER_MISSING_CANONICAL_ROUTE"
    exit 1
  }

echo
echo "=== C. IDENTIFY CURRENT PORT 3000 PROCESS ==="
PID="$(lsof -tiTCP:3000 -sTCP:LISTEN | head -1)"

test -n "$PID" || {
  echo "STOP=NO_PORT_3000_SERVER"
  exit 1
}

echo "PORT_3000_PID=$PID"
ps -p "$PID" -o pid=,ppid=,lstart=,command=

echo
echo "=== D. CONFIRM ACTIVE PROCESS IS SERVING STALE ROUTE SET ==="

APPROVAL_STATUS="$(
  curl -sS -o /tmp/motherboard-approval-response.txt \
    -w '%{http_code}' \
    'http://127.0.0.1:3000/api/approval-requests?project_id=hq'
)"

CANONICAL_STATUS="$(
  curl -sS -o /tmp/motherboard-canonical-response.txt \
    -w '%{http_code}' \
    'http://127.0.0.1:3000/api/canonical-packages?project_id=hq'
)"

echo "APPROVAL_REQUEST_STATUS=$APPROVAL_STATUS"
echo "CANONICAL_PACKAGE_STATUS=$CANONICAL_STATUS"

test "$APPROVAL_STATUS" = "200"
test "$CANONICAL_STATUS" = "404"

echo
echo "============================================================"
echo " CLASSIFICATION COMPLETE"
echo "============================================================"
echo "DEFECT_CLASS=STALE_BROWSER_FACING_SERVER_PROCESS"
echo "CURRENT_SOURCE_ROUTE_PRESENT=YES"
echo "CURRENT_COMPILED_ROUTE_PRESENT=YES"
echo "ACTIVE_PORT_3000_ROUTE_PRESENT=NO"
echo "PRODUCT_PATCH_REQUIRED=NO"
echo "DATABASE_MUTATED=NO"
echo "AUTHORITY_CHANGED=NO"
echo "NEXT_ACTION=RESTART_BROWSER_FACING_RUNTIME_FROM_CURRENT_BUILD"
echo "CLEAR_STOPPING_POINT=YES"
