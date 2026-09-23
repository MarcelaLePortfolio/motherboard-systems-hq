#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

echo "===== RECONCILED FIXTURE STATUS ====="
echo "CLOSED: reconciled-intent fixture now matches the Living Draft success-criteria schema and focused tests pass."

echo
echo "===== CURRENT HEAD / REMOTE ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'

echo
echo "===== DRAFT REVISION RUNTIME ====="
cat db/matilda-draft-revision-runtime.ts

echo
echo "===== RECONCILED SUMMARY RUNTIME ====="
cat db/matilda-reconciled-intent-runtime.ts

echo
echo "===== CANONICAL PACKAGE RUNTIME ====="
sed -n '1,430p' db/matilda-canonical-package-runtime.ts

echo
echo "===== CANONICAL READ REPOSITORY ====="
cat db/canonical-package-read-repository.ts

echo
echo "===== GOVERNANCE PROJECTION ====="
cat db/canonical-package-mission-projection.ts

echo
echo "===== FOCUSED TEST SURFACES ====="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'success_criteria|approved_success_criteria|expected_outcome|approved_expected_outcome|matilda_draft_revisions|matilda_canonical_packages' \
  db/matilda-reconciled-intent-runtime.test.ts \
  db/matilda-canonical-package-runtime.test.ts \
  db/canonical-package-mission-projection.test.ts \
  db/canonical-package-read-repository.delegation.test.ts \
  2>/dev/null | head -600

echo
echo "===== PRESERVED TRACKED DRIFT ====="
git status --short --untracked-files=no
