#!/usr/bin/env bash
set -euo pipefail

echo "==== Phase 423 files ===="
git show --name-only --format="" 1d45520a
git show --name-only --format="" 5dc2be91

echo
echo "==== Candidate symbols from commit 1d45520a ===="
git show 1d45520a | grep -E '^\+.*(execute|execution|proof|attempt|gate|activat|approv|authoriz|handler|run)' || true

echo
echo "==== Candidate symbols from commit 5dc2be91 ===="
git show 5dc2be91 | grep -E '^\+.*(execute|execution|proof|attempt|gate|activat|approv|authoriz|handler|run)' || true

echo
echo "==== Alternate entrypoint scan ===="
grep -R "executeProof" src || true
grep -R "runProof" src || true
grep -R "executionAttempt" src || true
grep -R "startExecution" src || true
grep -R "beginExecution" src || true

echo
echo "==== Candidate file list from Phase 423 commits ===="
git show --name-only --format="" 1d45520a 5dc2be91 | sed '/^$/d' | sort -u
