#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

BRANCH="feature/support-source-references-runtime"
EXPECTED_HEAD="1b2fa81b7"
PROJECT_ID="hq"
OUTPUT="docs/checkpoints/APPROVED_PACKAGE_LIVE_DELEGATION_PAYLOAD_DIAGNOSIS.txt"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$EXPECTED_HEAD"
test "$(git rev-parse HEAD)" = "$(git rev-parse "origin/$BRANCH")"

{
  echo "============================================================"
  echo " APPROVED CANONICAL PACKAGE — LIVE PAYLOAD DIAGNOSIS"
  echo "============================================================"

  echo
  echo "=== SERVER LISTENERS ==="
  lsof -nP -iTCP:3000 -sTCP:LISTEN || true
  lsof -nP -iTCP:3001 -sTCP:LISTEN || true

  echo
  echo "=== LIVE CANONICAL PACKAGE RESPONSE :3000 ==="
  curl -sS -i \
    "http://localhost:3000/api/canonical-packages?project_id=${PROJECT_ID}" \
    || true

  echo
  echo "=== LIVE CANONICAL PACKAGE RESPONSE :3001 ==="
  curl -sS -i \
    "http://localhost:3001/api/canonical-packages?project_id=${PROJECT_ID}" \
    || true

  echo
  echo "=== SOURCE CONTRACT REQUIRING DELEGATION ==="
  grep -n -A 45 \
    -E '^export interface CanonicalPackageReadModel|delegation: CanonicalPackageDelegationState' \
    client/src/approvals/canonicalPackageReadApi.ts || true

  echo
  echo "=== FIRST DETAIL RENDER ACCESS TO DELEGATION ==="
  grep -n -B 8 -A 16 \
    'pkg\.delegation\.state' \
    client/src/approvals/ApprovalsWorkspace.tsx || true

  echo
  echo "=== SERVER ROUTE / REPOSITORY BINDING ==="
  grep -Rni \
    -E 'canonical-packages|createCanonicalPackageReadRepository|listByProject' \
    server db \
    --include='*.ts' \
    --include='*.mjs' \
    | head -120 || true

  echo
  echo "=== COMPILED RUNTIME DELEGATION EVIDENCE ==="
  grep -Rni \
    -E 'awaiting_delegation|governance_delegations|delegationStatement' \
    dist \
    2>/dev/null \
    | head -120 || true

  echo
  echo "=== CLASSIFICATION TARGET ==="
  echo "HYPOTHESIS=LIVE_CANONICAL_PACKAGE_PAYLOAD_MAY_LACK_DELEGATION_PROJECTION"
  echo "PRODUCT_MUTATION_PERFORMED=NO"
  echo "DATABASE_MUTATION_PERFORMED=NO"
  echo "AUTHORITY_CHANGED=NO"
  echo "FIX_AUTHORIZED=NO"
  echo "NEXT_ACTION=CLASSIFY_LIVE_PAYLOAD_BEFORE_ANY_PRODUCT_FIX"
  echo "CLEAR_STOPPING_POINT=YES"
} | tee "$OUTPUT"

git diff --check -- "$OUTPUT"
