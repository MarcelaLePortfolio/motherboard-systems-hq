#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

echo "===== LIVING DRAFT CORRIDOR STATUS ====="
echo "CLOSED: success criteria now persists through Draft Synthesis -> Living Draft write -> Living Draft read."

echo
echo "===== CURRENT BASELINE ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'

echo
echo "===== DRAFT REVISION EXACT SURFACE ====="
sed -n '1,210p' db/matilda-draft-revision-runtime.ts

echo
echo "===== RECONCILED SUMMARY EXACT SURFACE ====="
sed -n '1,210p' db/matilda-reconciled-intent-runtime.ts

echo
echo "===== CANONICAL PACKAGE EXACT SURFACE ====="
sed -n '1,420p' db/matilda-canonical-package-runtime.ts

echo
echo "===== CANONICAL READ EXACT SURFACE ====="
cat db/canonical-package-read-repository.ts

echo
echo "===== GOVERNANCE PROJECTION EXACT SURFACE ====="
cat db/canonical-package-mission-projection.ts

echo
echo "===== RELEVANT TEST FIXTURES ====="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'expected_outcome|approved_expected_outcome|success_criteria|approved_success_criteria|matilda_draft_revisions|matilda_canonical_packages' \
  db/matilda-reconciled-intent-runtime.test.ts \
  db/matilda-canonical-package-runtime.test.ts \
  db/canonical-package-mission-projection.test.ts \
  db/canonical-package-read-repository.delegation.test.ts \
  2>/dev/null | head -500

echo
echo "===== PRESERVED TRACKED DRIFT ====="
git status --short --untracked-files=no
