#!/usr/bin/env bash
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

echo "=== INSPECT DELEGATION ROUTE AND DIRTY WORKTREE ==="

echo
echo "=== BASELINE ==="
printf "HEAD=" && git rev-parse --short=8 HEAD
printf "BRANCH=" && git branch --show-current

echo
echo "=== CURRENT WORKTREE ==="
git status --short

echo
echo "=== ROUTE BODY EXACT LIVE FRAGMENT ==="
sed -n '1,70p' server/routes/governance-delegation-route.ts

echo
echo "=== ROUTE REQUEST BUILDER EXACT LIVE FRAGMENT ==="
sed -n '115,165p' server/routes/governance-delegation-route.ts

echo
echo "=== CURRENT IMPLEMENTATION DIFFS ==="
git diff -- \
  db/governance-runtime.ts \
  server/delegation/production-delegation-consumer.ts \
  server/delegation/production-delegation-consumer.test.ts \
  server/delegation/production-delegation-entry-point.ts \
  server/delegation/production-delegation-entry-point.test.ts

echo
echo "=== UNTRACKED AUTHORIZED IMPLEMENTATION FILES ==="
for file in \
  drizzle/0010_project_scoped_delegation_reference.sql \
  scripts/validate-project-scoped-delegation-reference.mjs
do
  echo "--- $file ---"
  if [[ -f "$file" ]]; then
    sed -n '1,320p' "$file"
  else
    echo "MISSING"
  fi
done

echo
echo "=== UNEXPECTED UNTRACKED FILE ==="
if [[ -e "prompt," ]]; then
  ls -l "prompt,"
  echo "--- CONTENT ---"
  sed -n '1,160p' "prompt," 2>/dev/null || true
else
  echo "prompt,_PRESENT=NO"
fi

echo
echo "=== CLASSIFICATION ==="
echo "IMPLEMENTATION_AUTHORIZED=YES"
echo "IMPLEMENTATION_STARTED=YES"
echo "BOUNDED_VALIDATION_TESTS=PASS_PREVIOUSLY"
echo "SCHEMA_PROBE=PASS_PREVIOUSLY"
echo "TYPECHECK_CURRENT_BLOCKER=DELEGATION_ROUTE_PROJECT_ID_TRANSPORT"
echo "WORKTREE_CONTAINS_UNCOMMITTED_AUTHORIZED_IMPLEMENTATION=YES"
echo "UNEXPECTED_UNTRACKED_PROMPT_FILE_REQUIRES_CLASSIFICATION=YES"
echo "FAILED_HYPOTHESIS_COUNT_INCREMENT=NO"
echo "PRODUCTION_DATABASE_MIGRATION_APPLIED=NO"
echo "NEXT_ACTION=RECONCILE_EXACT_LOCAL_ROUTE_BODY_AND_UNEXPECTED_PROMPT_FILE_BEFORE_ANY_FURTHER_EDIT"
