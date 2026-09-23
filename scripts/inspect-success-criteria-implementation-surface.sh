#!/usr/bin/env bash
set -euo pipefail

echo "===== PACKAGE SEMANTICS TYPE + VALIDATION ====="
grep -n -B 30 -A 170 \
  -E 'MatildaPackageSemanticsArtifact|validateMatildaPackageSemanticsArtifact|packageSemanticsFields|expectedOutcome|unresolvedQuestions' \
  scripts/utils/ollamaChat.ts | head -1000

echo
echo "===== IEL PACKAGE SEMANTICS PERSISTENCE ====="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'packageSemantics|expectedOutcome|proposedWork|unresolvedQuestions' \
  db/matilda-interpretation-runtime.ts \
  db/matilda-conversation-runtime.ts \
  server/matilda-chat-workflow.ts \
  2>/dev/null | head -800

echo
echo "===== LIVING DRAFT READ RUNTIME ====="
cat db/matilda-living-draft-read-runtime.ts

echo
echo "===== DRAFT REVISION TYPE + INSERT ====="
sed -n '1,190p' db/matilda-draft-revision-runtime.ts

echo
echo "===== RECONCILED SUMMARY TYPE + ASSEMBLY ====="
sed -n '1,155p' db/matilda-reconciled-intent-runtime.ts

echo
echo "===== CANONICAL READ CONTRACT ====="
sed -n '1,190p' db/canonical-package-read-repository.ts

echo
echo "===== SUCCESS CRITERIA TEST SURFACES ====="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  -E 'expectedOutcome|expected_outcome|approved_expected_outcome|successCriteria|success_criteria' \
  scripts/utils/ollamaChat*.test.ts \
  db/*draft*.test.ts \
  db/*reconciled*.test.ts \
  db/*canonical*.test.ts \
  2>/dev/null | head -1200

echo
echo "===== BASELINE / PRESERVED DRIFT ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'
git status --short --untracked-files=no
