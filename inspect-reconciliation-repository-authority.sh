#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/marcela-dev/Projects/motherboard-systems-hq-clean"
BRANCH="feature/support-source-references-runtime"

cd "$ROOT"

printf '\n=== BASELINE ===\n'
git fetch origin "$BRANCH"
git status --short
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse "origin/$BRANCH")"

printf '\n=== PROJECT REGISTRY AUTHORITY ===\n'
sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT * FROM project_registry;
SQL

printf '\n=== RECONCILIATION IMPLEMENTATION ===\n'
grep -RniE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  '(reconciliation|canonical.*identity|entity.*classification|entity.*registry|identity.*registry|actor.*registry|agent.*registry)' \
  server db client/src docs scripts \
  2>/dev/null || true

printf '\n=== NAMED AGENT REFERENCES ===\n'
grep -RniE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  '(\bMatilda\b|\bCade\b|\bEffie\b|Chief of Staff)' \
  server db client/src docs scripts \
  2>/dev/null || true

printf '\n=== NEIGHBORING GIT REPOSITORIES ===\n'
find /Users/marcela-dev/Projects \
  -mindepth 1 \
  -maxdepth 3 \
  -type d \
  -name .git \
  -print 2>/dev/null |
while read -r gitdir; do
  repo="${gitdir%/.git}"
  printf '\nREPOSITORY=%s\n' "$repo"
  printf 'BRANCH=%s\n' "$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  printf 'HEAD=%s\n' "$(git -C "$repo" rev-parse HEAD 2>/dev/null || true)"
done

printf '\n=== CLASSIFICATION ===\n'
echo 'REPOSITORY_AUTHORITY_INFERRED=NO'
echo 'IDENTITY_AUTHORITY_INFERRED=NO'
echo 'MATILDA_EQUALS_CHIEF_OF_STAFF=NO'
echo 'MUTATION_PERFORMED=NO'
echo 'NEXT_STEP=CLASSIFY_FROM_EVIDENCE_ONLY'

printf '\n=== FINAL STATUS ===\n'
git status --short
