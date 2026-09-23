#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="61c82cb7e"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

echo "===== CANONICAL PACKAGE RUNTIME ====="
grep -n -B 30 -A 90 \
  -E 'createCanonicalPackageTable|migrateLegacyCanonicalPackageTableIfRequired|approved_expected_outcome|createCanonicalPackageFromApprovedSummary|delegation_authorized|validation_authorized|envelope_authorized|execution_authorized' \
  db/matilda-canonical-package-runtime.ts

echo
echo "===== CANONICAL READ REPOSITORY ====="
grep -n -B 25 -A 70 \
  -E 'CanonicalPackageReadRecord|approved_expected_outcome|SELECT' \
  db/canonical-package-read-repository.ts

echo
echo "===== GOVERNANCE PROJECTION ====="
grep -n -B 30 -A 110 \
  -E 'CanonicalProjectionSource|approved_expected_outcome|success_criteria|exactProjectionMatch|INSERT INTO governance_packages|delegation_authorized|validation_authorized|envelope_authorized|execution_authorized' \
  db/canonical-package-mission-projection.ts

echo
echo "===== FOCUSED TEST SURFACES ====="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'approved_expected_outcome|approved_success_criteria|success_criteria|matilda_canonical_packages|governance_packages' \
  db/matilda-canonical-package-runtime.test.ts \
  db/canonical-package-mission-projection.test.ts \
  db/canonical-package-read-repository.delegation.test.ts \
  2>/dev/null | head -500

echo
echo "===== HEAD / REMOTE ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'

echo
echo "===== PRESERVED TRACKED DRIFT ====="
git status --short --untracked-files=no
