#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

BRANCH="feature/support-source-references-runtime"
BASELINE="d69b4fc97"

test "$(git branch --show-current)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 '@{u}')" = "$BASELINE"

echo "===== PACKAGE SEMANTICS ====="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'successCriteria|success_criteria' \
  scripts/utils/ollamaChat.ts \
  scripts/validate-package-semantics-iel-draft-transport.test.ts \
  server/matilda-chat-workflow.ts \
  2>/dev/null || true

echo
echo "===== LIVING DRAFT ====="
grep -Rni \
  -E 'successCriteria|success_criteria' \
  db/matilda-draft-synthesis-runtime.ts \
  db/matilda-living-draft-runtime.ts \
  db/matilda-living-draft-read-runtime.ts

echo
echo "===== DRAFT REVISION / RECONCILED SUMMARY ====="
grep -Rni \
  -E 'successCriteria|success_criteria' \
  db/matilda-draft-revision-runtime.ts \
  db/matilda-reconciled-intent-runtime.ts \
  db/approval-request-model-assembler.ts

echo
echo "===== CANONICAL / GOVERNANCE ====="
grep -Rni \
  -E 'approved_success_criteria|success_criteria' \
  db/matilda-canonical-package-runtime.ts \
  db/canonical-package-read-repository.ts \
  db/canonical-package-mission-projection.ts

echo
echo "===== AUTHORITY BOUNDARY ====="
grep -n \
  -E 'delegation_authorized|validation_authorized|envelope_authorized|execution_authorized' \
  db/matilda-canonical-package-runtime.ts \
  db/canonical-package-mission-projection.ts

echo
echo "===== TYPECHECK ====="
npx tsc --noEmit

echo
echo "===== FOCUSED LINEAGE TESTS ====="
node --import tsx --test \
  db/matilda-reconciled-intent-runtime.test.ts \
  db/matilda-canonical-package-runtime.test.ts \
  db/canonical-package-mission-projection.test.ts \
  db/canonical-package-read-repository.delegation.test.ts

echo
echo "===== SEMANTIC TRANSPORT TEST ====="
node --import tsx --test \
  scripts/validate-package-semantics-iel-draft-transport.test.ts || true

echo
echo "===== WORKTREE ====="
git status --short --untracked-files=no
