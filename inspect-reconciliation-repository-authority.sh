#!/usr/bin/env bash
set -u

ROOT="/Users/marcela-dev/Projects/motherboard-systems-hq-clean"
BRANCH="feature/support-source-references-runtime"

cd "$ROOT" || exit 1

printf '\n=== BASELINE ===\n'
git fetch origin "$BRANCH"
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse "origin/$BRANCH")"
printf '\nWORKTREE:\n'
git status --short

printf '\n=== PROJECT REGISTRY SCHEMA ===\n'
sqlite3 db/main.db "PRAGMA table_info(project_registry);" || true

printf '\n=== PROJECT REGISTRY ROWS ===\n'
sqlite3 -header -column db/main.db "SELECT * FROM project_registry;" || true

printf '\n=== RECONCILIATION / IDENTITY IMPLEMENTATION ===\n'
grep -RniE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  '(reconciliation|canonical.*identity|entity.*classification|entity.*registry|identity.*registry|actor.*registry|agent.*registry)' \
  server db client/src docs scripts \
  2>/dev/null | head -n 500 || true

printf '\n=== NAMED AGENT REFERENCES ===\n'
grep -RniE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  '(\bMatilda\b|\bCade\b|\bEffie\b|Chief of Staff)' \
  server db client/src docs scripts \
  2>/dev/null | head -n 500 || true

printf '\n=== NEIGHBORING GIT REPOSITORIES ===\n'
find /Users/marcela-dev/Projects \
  -mindepth 1 \
  -maxdepth 3 \
  -type d \
  -name .git \
  -print 2>/dev/null |
while IFS= read -r gitdir; do
  repo="${gitdir%/.git}"
  printf '\nREPOSITORY=%s\n' "$repo"
  printf 'BRANCH=%s\n' "$(git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
  printf 'HEAD=%s\n' "$(git -C "$repo" rev-parse HEAD 2>/dev/null || true)"
  printf 'REMOTE=%s\n' "$(git -C "$repo" remote get-url origin 2>/dev/null || true)"
done

printf '\n=== EVIDENCE-ONLY CLASSIFICATION ===\n'
echo 'REPOSITORY_AUTHORITY_INFERRED=NO'
echo 'IDENTITY_AUTHORITY_INFERRED=NO'
echo 'MATILDA_EQUALS_CHIEF_OF_STAFF=NO'
echo 'MUTATION_PERFORMED_BY_INSPECTION=NO'
echo 'NEXT_STEP=CLASSIFY_FROM_CAPTURED_EVIDENCE_ONLY'

printf '\n=== FINAL STATUS ===\n'
git status --short
