#!/usr/bin/env bash
set -euo pipefail

echo "===== CURRENT BASELINE ====="
printf "BRANCH: "; git branch --show-current
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'

echo
echo "===== PACKAGE SEMANTICS SUB-CORRIDOR COMMIT ====="
git show --stat --oneline d78df0810

echo
echo "===== LIVING DRAFT INPUT / SCHEMA / WRITE ====="
grep -n -B 20 -A 220 \
  -E 'UpsertLivingDraftPackageInput|CREATE TABLE IF NOT EXISTS matilda_living_draft_packages|expected_outcome|INSERT INTO matilda_living_draft_packages' \
  db/matilda-living-draft-runtime.ts

echo
echo "===== DRAFT SYNTHESIS ====="
sed -n '65,130p' db/matilda-draft-synthesis-runtime.ts

echo
echo "===== DRAFT REVISION ====="
grep -n -B 20 -A 190 \
  -E 'DraftRevisionRecord|CREATE TABLE IF NOT EXISTS matilda_draft_revisions|INSERT INTO matilda_draft_revisions' \
  db/matilda-draft-revision-runtime.ts

echo
echo "===== RECONCILED SUMMARY ====="
cat db/matilda-reconciled-intent-runtime.ts

echo
echo "===== CANONICAL PACKAGE ====="
grep -n -B 20 -A 260 \
  -E 'CREATE TABLE IF NOT EXISTS matilda_canonical_packages|approved_expected_outcome|INSERT INTO matilda_canonical_packages' \
  db/matilda-canonical-package-runtime.ts

echo
echo "===== GOVERNANCE PROJECTION ====="
cat db/canonical-package-mission-projection.ts

echo
echo "===== CURRENT PRESERVED DRIFT ====="
git status --short --untracked-files=no
