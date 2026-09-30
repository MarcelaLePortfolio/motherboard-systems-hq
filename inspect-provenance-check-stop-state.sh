#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"

printf '\n=== REPOSITORY STATE ===\n'
printf 'CURRENT_BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'LOCAL_HEAD=%s\n' "$(git rev-parse --short=9 HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse --short=9 "origin/$BRANCH")"

printf '\n=== DIVERGENCE ===\n'
git rev-list --left-right --count "HEAD...origin/$BRANCH"

printf '\n=== STAGED PATHS ===\n'
git diff --cached --name-only

printf '\n=== UNSTAGED PATHS ===\n'
git diff --name-only

printf '\n=== UNTRACKED RELEVANT CHECK SCRIPT ===\n'
git status --short -- verify-runtime-lifecycle-provenance-now.sh

printf '\n=== RECENT COMMITS ===\n'
git log --oneline -8

printf '\n=== CLASSIFICATION ===\n'
echo 'IMPLEMENTATION_PERFORMED=NO'
echo 'NEXT_STEP=IDENTIFY_FAILED_PRECONDITION_FROM_STATE_ABOVE'
