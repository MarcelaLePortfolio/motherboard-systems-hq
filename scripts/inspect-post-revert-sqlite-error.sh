#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

echo "===== POST-REVERT CLASSIFICATION ====="
echo "The revert restored source state but did not restore a passing runtime baseline."
echo "No further implementation will be attempted until the SQLITE_ERROR is identified."

echo
echo "===== CURRENT HEAD / REMOTE ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'

echo
echo "===== REVERT / PRE-ATTEMPT HISTORY ====="
git log -6 --oneline --decorate

echo
echo "===== LIVE DRAFT REVISION SCHEMA ====="
sqlite3 -header -column db/main.db "PRAGMA table_info(matilda_draft_revisions);"

echo
echo "===== LIVE LIVING DRAFT SCHEMA ====="
sqlite3 -header -column db/main.db "PRAGMA table_info(matilda_living_draft_packages);"

echo
echo "===== SOURCE DRAFT REVISION CREATE SCHEMA ====="
sed -n '1,190p' db/matilda-draft-revision-runtime.ts

echo
echo "===== RECONCILED TEST ====="
cat db/matilda-reconciled-intent-runtime.test.ts

echo
echo "===== ISOLATED FAILING TEST ====="
node --import tsx --test db/matilda-reconciled-intent-runtime.test.ts || true

echo
echo "===== DATABASE INTEGRITY ====="
sqlite3 db/main.db "PRAGMA integrity_check;"

echo
echo "===== PRESERVED TRACKED DRIFT ====="
git status --short --untracked-files=no
