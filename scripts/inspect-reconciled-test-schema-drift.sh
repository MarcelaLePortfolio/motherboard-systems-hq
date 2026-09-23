#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

echo "===== CLASSIFICATION ====="
echo "Database integrity is OK, but the reconciled-intent fixture still creates the pre-success-criteria Living Draft schema."
echo "The live Living Draft table also lacks success_criteria, so initialization/migration behavior must be established before repair."

echo
echo "===== CURRENT HEAD / REMOTE ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'

echo
echo "===== LIVING DRAFT READ RUNTIME ====="
cat db/matilda-living-draft-read-runtime.ts

echo
echo "===== LIVING DRAFT INITIALIZATION / MIGRATION ====="
grep -n -B 30 -A 120 \
  -E 'initializeLivingDraft|success_criteria|ALTER TABLE|PRAGMA table_info' \
  db/matilda-living-draft-runtime.ts

echo
echo "===== INITIALIZER CALL SITES ====="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'initializeLivingDraftPackageSchema|initializeLivingDraftSchema' \
  db server scripts 2>/dev/null | head -250

echo
echo "===== RECONCILED TEST FIXTURE ====="
sed -n '288,405p' db/matilda-reconciled-intent-runtime.test.ts

echo
echo "===== LIVE LIVING DRAFT SCHEMA ====="
sqlite3 -header -column db/main.db \
  "PRAGMA table_info(matilda_living_draft_packages);"

echo
echo "===== DATABASE INTEGRITY ====="
sqlite3 db/main.db "PRAGMA integrity_check;"

echo
echo "===== PRESERVED TRACKED DRIFT ====="
git status --short --untracked-files=no
