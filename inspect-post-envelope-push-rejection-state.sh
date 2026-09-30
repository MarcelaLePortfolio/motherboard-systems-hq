#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"

git fetch origin "$BRANCH"

printf '\n=== HEAD STATE ===\n'
printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"
printf 'DIVERGENCE='
git rev-list --left-right --count "HEAD...origin/$BRANCH"

printf '\n=== RECENT LOCAL COMMITS ===\n'
git log --oneline -5

printf '\n=== IMPLEMENTATION COMMIT PRESENCE ===\n'
git show --no-patch --oneline 8c0ceba40

printf '\n=== BOOKKEEPING COMMIT PRESENCE ===\n'
git show --no-patch --oneline 6576d9b82

printf '\n=== STAGED PATHS ===\n'
git diff --cached --name-only

printf '\n=== UNSTAGED PATHS ===\n'
git diff --name-only

printf '\n=== CLASSIFICATION ===\n'
if git merge-base --is-ancestor "origin/$BRANCH" HEAD; then
  echo 'FAST_FORWARD_PUSH_POSSIBLE=YES'
else
  echo 'FAST_FORWARD_PUSH_POSSIBLE=NO'
fi

if git merge-base --is-ancestor 8c0ceba40 "origin/$BRANCH"; then
  echo 'IMPLEMENTATION_COMMIT_REMOTE=YES'
else
  echo 'IMPLEMENTATION_COMMIT_REMOTE=NO'
fi

if git merge-base --is-ancestor 6576d9b82 "origin/$BRANCH" 2>/dev/null; then
  echo 'BOOKKEEPING_COMMIT_REMOTE=YES'
else
  echo 'BOOKKEEPING_COMMIT_REMOTE=NO'
fi

echo 'NEXT_STEP=ONLY_PUSH_IF_REMOTE_IS_ANCESTOR_OF_LOCAL_AND_IMPLEMENTATION_IS_ALREADY_REMOTE'

git add -- inspect-post-envelope-push-rejection-state.sh
git commit -m "Inspect post-envelope push rejection state"
git push origin "$BRANCH"
