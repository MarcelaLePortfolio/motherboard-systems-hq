#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"
test -z "$(git diff --cached --name-only)"

printf '\n=== CLOSED ATLAS CORRIDOR CHECKPOINT ===\n'
echo "ATLAS_QA_EVIDENCE_PERSISTENCE_AND_DOGFOOD_LIFECYCLE_CORRIDOR=CLOSED"
echo "ATLAS_CLOSURE_COMMIT=a3e4dc1a5a7a793697e90e32c2f492d195043f73"
echo "APPROVALS_EXECUTIVE_INBOX_ISSUE=SEPARATE"

printf '\n=== APPROVALS INVESTIGATION BOUNDARY ===\n'
echo "MODE=DIAGNOSTIC_ONLY"
echo "APPROVALS_FIX_AUTHORIZED=NO"
echo "PRODUCT_MUTATION_AUTHORIZED=NO"
echo "DATABASE_MUTATION_AUTHORIZED=NO"

printf '\n=== LOCATE EXECUTIVE INBOX DATA LOAD ===\n'
grep -n -A180 -B80 \
  -E 'Unable to load Executive Inbox|fetch\(|load|approval|request' \
  client/src/approvals/ApprovalsWorkspace.tsx \
  | head -n 520 || true

printf '\n=== LOCATE APPROVALS API CLIENTS ===\n'
grep -RIn \
  --exclude-dir=node_modules \
  --exclude-dir=dist \
  --exclude-dir=.git \
  -E 'approval-requests|Executive Inbox|ApprovalsWorkspace|fetch\(' \
  client/src routes server \
  | head -n 520 || true

printf '\n=== INSPECT APPROVAL REQUEST SERVER ROUTE ===\n'
if [ -f routes/api-approval-request.ts ]; then
  sed -n '1,320p' routes/api-approval-request.ts
fi

printf '\n=== INSPECT SERVER MOUNT ===\n'
grep -n -A20 -B20 \
  'approvalRequestRouter' \
  server/index.ts || true

printf '\n=== CHECK LOCAL SERVER ENDPOINTS ===\n'
for PORT in 3000 3001; do
  printf '\n--- PORT %s ---\n' "$PORT"

  curl -sS -o "/tmp/approvals-$PORT.body" \
    -w 'HTTP_STATUS=%{http_code}\n' \
    "http://127.0.0.1:$PORT/api/approval-requests" \
    || true

  if [ -f "/tmp/approvals-$PORT.body" ]; then
    head -c 3000 "/tmp/approvals-$PORT.body"
    printf '\n'
  fi
done

printf '\n=== VERIFY NO MUTATION ===\n'
test -z "$(git diff --cached --name-only)"

git diff --exit-code -- \
  client/src/approvals/ApprovalsWorkspace.tsx \
  routes/api-approval-request.ts \
  server/index.ts

printf '\n=== CLASSIFICATION ===\n'
echo "ATLAS_CORRIDOR_REOPENED=NO"
echo "APPROVALS_EXECUTIVE_INBOX_DIAGNOSIS=IN_PROGRESS"
echo "APPROVALS_FIX_EXECUTED=NO"
echo "PRODUCT_CODE_CHANGED=NO"
echo "DATABASE_MUTATED=NO"
echo "CLEAR_STOPPING_POINT=YES"
echo "NEXT_ACTION=CLASSIFY_EXACT_EXECUTIVE_INBOX_FAILURE_FROM_ENDPOINT_AND_CLIENT_EVIDENCE"
