#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"

printf '\n=== BRANCH STATE ===\n'
echo "BRANCH=$(git rev-parse --abbrev-ref HEAD)"
echo "LOCAL_HEAD=$(git rev-parse --short=9 HEAD)"
echo "REMOTE_HEAD=$(git rev-parse --short=9 "origin/$BRANCH")"

printf '\n=== TARGET STATUS ===\n'
git status --short -- \
  db/governance-validation-read-repository.ts \
  server/validation/production-validation-consumer.ts \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.test.ts

printf '\n=== STAGED TARGETS ===\n'
git diff --cached --name-status -- \
  db/governance-validation-read-repository.ts \
  server/validation/production-validation-consumer.ts \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.test.ts

printf '\n=== UNSTAGED TARGETS ===\n'
git diff --name-status -- \
  db/governance-validation-read-repository.ts \
  server/validation/production-validation-consumer.ts \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.test.ts

printf '\n=== STAGED COUNT ===\n'
git diff --cached --name-only -- \
  db/governance-validation-read-repository.ts \
  server/validation/production-validation-consumer.ts \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.test.ts | wc -l | tr -d ' '

printf '\n=== UNSTAGED COUNT ===\n'
git diff --name-only -- \
  db/governance-validation-read-repository.ts \
  server/validation/production-validation-consumer.ts \
  server/routes/governance-validation-route.ts \
  server/validation/production-validation-consumer.test.ts \
  server/routes/governance-validation-route.test.ts | wc -l | tr -d ' '

printf '\n=== NEW READER PRESENCE ===\n'
if [ -e db/governance-validation-read-repository.ts ]; then
  echo "NEW_READER_EXISTS=YES"
else
  echo "NEW_READER_EXISTS=NO"
fi

printf '\n=== IMPLEMENTATION COMMIT SEARCH ===\n'
git log --oneline --all --grep='Enforce validation delegation eligibility' -5 || true

printf '\n=== PRESERVED WORKTREE ===\n'
git status --short

printf '\nVALIDATION_REPAIR_INDEX_STATE_INSPECTION=COMPLETE\n'
