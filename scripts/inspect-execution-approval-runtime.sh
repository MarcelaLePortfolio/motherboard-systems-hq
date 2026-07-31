#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

printf '\n========== EXECUTION PREVIEW RUNTIME ==========\n'
sed -n '1,320p' db/matilda-preview-runtime.ts

printf '\n========== PREVIEW CONFIRMATION RUNTIME ==========\n'
sed -n '1,320p' db/matilda-preview-confirmation-runtime.ts

printf '\n========== EXECUTION AUTHORIZATION RUNTIME ==========\n'
sed -n '1,320p' db/matilda-execution-authorization-runtime.ts

printf '\n========== EXECUTION PLANNING ROUTE ==========\n'
sed -n '1,320p' server/routes/matilda-execution-planning-route.ts

printf '\n========== PREVIEW ROUTE ==========\n'
sed -n '1,320p' server/routes/matilda-preview-route.ts

printf '\n========== PREVIEW CONFIRMATION ROUTE ==========\n'
sed -n '1,320p' server/routes/matilda-preview-confirmation-route.ts

printf '\n========== EXECUTION AUTHORIZATION FILES ==========\n'
find server routes db \
  -type f \
  \( \
    -iname '*execution*authorization*' \
    -o -iname '*execution*approval*' \
  \) \
  -print |
while IFS= read -r file; do
  printf '\n----- %s -----\n' "$file"
  sed -n '1,320p' "$file"
done

printf '\n========== ACTIVE SERVER REGISTRATION ==========\n'
git grep -nE \
  'executionPlanning|previewRouter|previewConfirmation|executionAuthorization|matilda-preview|matilda-execution' \
  -- server/index.ts server/routes routes \
  2>/dev/null || true

printf '\n========== APPROVAL ARTIFACT BUILDER ==========\n'
sed -n '1,360p' server/execution/build-approval-artifact.mjs

printf '\n========== EXECUTION APPROVAL GATE ==========\n'
sed -n '1,360p' server/execution/execution-approval-gate.mjs

printf '\n========== PREVIEW APPROVAL RECONCILIATION ==========\n'
sed -n '1,320p' docs/contracts/PREVIEW_APPROVAL_RECONCILIATION_FINDING.md

printf '\n========== CANONICAL EXECUTION LIFECYCLE ==========\n'
sed -n '340,470p' docs/contracts/CANONICAL_EXECUTION_LIFECYCLE.md

printf '\n========== EXECUTION PERSISTENCE SEARCH ==========\n'
git grep -nEi \
  -e 'INSERT INTO.*execution' \
  -e 'UPDATE.*execution' \
  -e 'CREATE TABLE.*execution' \
  -e 'INSERT INTO.*preview' \
  -e 'UPDATE.*preview' \
  -e 'CREATE TABLE.*preview' \
  -e 'approval_artifact' \
  -- db server routes \
  2>/dev/null || true

printf '\n========== DATABASE OBJECTS ==========\n'
sqlite3 -header -column db/main.db "
SELECT type, name
FROM sqlite_master
WHERE lower(name) LIKE '%execution%'
   OR lower(name) LIKE '%preview%'
   OR lower(name) LIKE '%approval_artifact%'
ORDER BY type, name;
" 2>/dev/null || true

printf '\n========== QUESTIONS TO RESOLVE ==========\n'
printf '%s\n' \
  '1. Are execution plans, previews, confirmations, and authorizations persisted or in-memory only?' \
  '2. Are their routes mounted in the active server?' \
  '3. Does preview confirmation merely acknowledge evidence, or authorize execution?' \
  '4. Is execution authorization a separate explicit command?' \
  '5. Can the approval artifact carry visual or multimodal evidence?' \
  '6. Which verified gates should appear in the Approvals inbox?'

printf '\n========== FINAL STATUS ==========\n'
git status --short
