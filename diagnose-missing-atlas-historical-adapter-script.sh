#!/usr/bin/env bash
set -euo pipefail

cd "/Users/marcela-dev/Projects/motherboard-systems-hq-clean" || exit 1

BRANCH="feature/support-source-references-runtime"
SCRIPT="implement-atlas-historical-observation-adapter-attempt-1.sh"

printf '\n=== VERIFY CURRENT BASELINE ===\n'
git fetch origin "$BRANCH"

printf 'LOCAL_HEAD='
git rev-parse --short=9 HEAD
printf 'REMOTE_HEAD='
git rev-parse --short=9 "origin/$BRANCH"
printf 'RELATIONSHIP='
git rev-list --left-right --count "HEAD...origin/$BRANCH"

test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-list --left-right --count "HEAD...origin/$BRANCH")" = $'0\t0'

printf '\n=== SEARCH FOR MISSING IMPLEMENTATION SCRIPT ===\n'
find . -maxdepth 4 -type f -name "$SCRIPT" -print

printf '\n=== SEARCH TRACKED STATE ===\n'
git ls-files '*atlas-historical-observation-adapter*'

printf '\n=== SEARCH HISTORY ===\n'
git log --all --oneline --decorate -- "$SCRIPT"

printf '\n=== VERIFY PRODUCT FILES WERE NOT CREATED ===\n'
for file in \
  server/atlas/atlas-historical-observation-adapter.ts \
  server/atlas/atlas-historical-observation-adapter.test.ts
do
  if [ -e "$file" ]; then
    echo "UNEXPECTED_PRESENT=$file"
    exit 1
  else
    echo "ABSENT=$file"
  fi
done

printf '\n=== VERIFY WORKFLOW WAS NOT MUTATED BY THIS ATTEMPT ===\n'
git diff -- server/matilda-chat-workflow.ts

printf '\n=== VERIFY PROTECTED ATLAS FILES ===\n'
git diff --exit-code -- \
  server/atlas/atlas-preexecution-read-model.ts \
  server/atlas/atlas-preexecution-observation-aggregator.ts \
  server/atlas/atlas-preexecution-structural-reasoner.ts

printf '\n=== VERIFY NOTHING STAGED ===\n'
git diff --cached --name-status
test -z "$(git diff --cached --name-only)"

printf '\n=== CLASSIFICATION ===\n'
echo "ATTEMPT_1_IMPLEMENTATION_EXECUTED=NO"
echo "FAILURE_CLASS=MISSING_LOCAL_SCRIPT"
echo "FAILED_IMPLEMENTATION_HYPOTHESIS_COUNT=0"
echo "PRODUCT_MUTATION=NO"
echo "NEXT_ACTION=RECREATE_ALREADY_AUTHORIZED_IMPLEMENTATION_SCRIPT"
echo "SAFE_TO_CONTINUE=YES"

printf '\n=== STOP — NO PRODUCT MUTATION / COMMIT / PUSH ===\n'
