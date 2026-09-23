#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

echo "===== CLASSIFICATION ====="
echo "The repair stopped before mutation because its assumed reconciled-intent import anchor does not match the actual test file."
echo "Do not retry implementation until the exact import and fixture boundaries are captured."

echo
echo "===== HEAD / REMOTE ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'

echo
echo "===== RECONCILED TEST IMPORTS ====="
sed -n '1,80p' db/matilda-reconciled-intent-runtime.test.ts

echo
echo "===== GENERATOR REFERENCES ====="
grep -n -B 12 -A 12 \
  'generateReconciledIntentSummary' \
  db/matilda-reconciled-intent-runtime.test.ts || true

echo
echo "===== LIVING DRAFT FIXTURE BOUNDARY ====="
grep -n -B 20 -A 100 \
  -E 'CREATE TABLE.*matilda_living_draft_packages|expected_outcome TEXT|success_criteria TEXT' \
  db/matilda-reconciled-intent-runtime.test.ts || true

echo
echo "===== ACTUAL LIVING DRAFT INITIALIZER DECLARATION ====="
grep -n -B 15 -A 45 \
  -E 'function .*LivingDraft|success_criteria|ALTER TABLE' \
  db/matilda-living-draft-runtime.ts | head -220

echo
echo "===== FAILED-ATTEMPT TARGET DIFF ====="
git diff -- \
  db/matilda-living-draft-runtime.ts \
  db/matilda-reconciled-intent-runtime.test.ts

echo
echo "===== PRESERVED TRACKED DRIFT ====="
git status --short --untracked-files=no
