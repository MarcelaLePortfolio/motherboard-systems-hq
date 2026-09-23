#!/usr/bin/env bash
set -euo pipefail

cd /Users/marcela-dev/Projects/motherboard-systems-hq-clean

echo "===== VALIDATOR REGION ====="
sed -n '300,450p' scripts/utils/ollamaChat.ts

echo
echo "===== PACKAGE SEMANTICS FIELD CONTRACT ====="
grep -n -B 25 -A 100 \
  -E 'expectedOutcome|proposedWork|Object.keys|packageSemanticsFields|unknown' \
  scripts/utils/ollamaChat.ts | head -550

echo
echo "===== PACKAGE SEMANTICS PROMPT CONTRACT ====="
grep -n -B 40 -A 150 \
  -E 'For expectedOutcome|packageSemantics|proposedWork|unresolvedQuestions' \
  scripts/utils/ollamaChat.ts | head -750

echo
echo "===== SUCCESSCRITERIA OCCURRENCES ====="
grep -Rni \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  'successCriteria' \
  scripts/utils/ollamaChat.ts \
  scripts/utils/ollamaChat*.test.ts \
  server/matilda-chat-workflow.ts \
  db 2>/dev/null || true

echo
echo "===== CURRENT STATE ====="
printf "HEAD:   "; git rev-parse --short=12 HEAD
printf "REMOTE: "; git rev-parse --short=12 '@{u}'
git status --short
git diff --cached --stat
git diff --stat
