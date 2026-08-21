#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

printf '\n============================================================\n'
printf '🚦 CORRIDOR 3 · AUTHORITATIVE PACKAGE LINEAGE RECONCILIATION\n'
printf 'STATUS: 🟢 ACTIVE · LIVE HANDOFF CLASSIFICATION\n'
printf '============================================================\n\n'

printf '%s\n' \
'DR_CHECKPOINT=20260820_170737' \
'MATILDA_DOWNSTREAM_ROUTES_MOUNTED=NO_EVIDENCE' \
'GOVERNANCE_DOWNSTREAM_ROUTES_MOUNTED=NO_EVIDENCE' \
'CANONICAL_PACKAGE_ROUTE_MOUNTED=YES' \
'IMPLEMENTATION_AUTHORIZED=NO'

printf '\n=== ACTIVE SERVER INDEX ===\n'
sed -n '1,180p' server/index.ts

printf '\n=== CANONICAL PACKAGE RESULT CONSUMERS ===\n'
grep -Rni \
  --exclude='*.test.ts' \
  --exclude='*.bak' \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'createCanonicalPackageFromApprovedSummary|/api/matilda/canonical-package|matilda_canonical_packages' \
  server routes db client/src 2>/dev/null | head -360 || true

printf '\n=== DELEGATION ENTRY SURFACES ===\n'
grep -Rni \
  --exclude='*.test.ts' \
  --exclude='*.bak' \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E '/api/matilda/delegation|/api/governance/delegation|createDelegation\(|createGovernanceDelegation\(|consumeProductionDelegationEntryPoint' \
  server routes db client/src 2>/dev/null | head -360 || true

printf '\n=== PACKAGE → DELEGATION AUTOMATIC HANDOFF SEARCH ===\n'
grep -Rni \
  --exclude='*.test.ts' \
  --exclude='*.bak' \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=.next \
  --exclude-dir=dist \
  -E 'canonical.*delegat|package.*delegat|delegat.*canonical|delegat.*package' \
  server routes db client/src 2>/dev/null | head -360 || true

printf '\n=== CURRENT CLASSIFICATION BOUNDARY ===\n'
printf '%s\n' \
'QUESTION=Does the mounted Canonical Package runtime have any mounted or direct downstream Delegation handoff?' \
'IF_NO=LIVE_LIFECYCLE_CURRENTLY_TERMINATES_AT_CANONICAL_PACKAGE' \
'IF_YES=TRACE_ONLY_THE_VERIFIED_HANDOFF' \
'DO_NOT_INFER_DOWNSTREAM_AUTHORITY_FROM_UNMOUNTED_ROUTE_FILES=YES' \
'IMPLEMENTATION_AUTHORIZED=NO' \
'PRODUCTION_CHANGE=NONE'
