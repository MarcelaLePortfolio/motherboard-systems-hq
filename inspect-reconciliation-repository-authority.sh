#!/usr/bin/env bash
set -euo pipefail

ROOT="/Users/marcela-dev/Projects/motherboard-systems-hq-clean"
BRANCH="feature/support-source-references-runtime"

cd "$ROOT"

printf '\n=== CURRENT REPOSITORY BASELINE ===\n'
git fetch origin "$BRANCH"
printf 'REPOSITORY=%s\n' "$(basename "$(git rev-parse --show-toplevel)")"
printf 'BRANCH=%s\n' "$(git rev-parse --abbrev-ref HEAD)"
printf 'HEAD=%s\n' "$(git rev-parse HEAD)"
printf 'REMOTE_HEAD=%s\n' "$(git rev-parse "origin/$BRANCH")"
git status --short

printf '\n=== PROJECT REGISTRY ===\n'
if [ -f db/main.db ]; then
  sqlite3 db/main.db <<'SQL'
.headers on
.mode column
SELECT * FROM project_registry;
SQL
fi

printf '\n=== RECONCILIATION / ENTITY AUTHORITY REFERENCES ===\n'
grep -RniE \
  --exclude-dir=node_modules \
  --exclude-dir=.git \
  --exclude-dir=dist \
  --include='*.ts' \
  --include='*.tsx' \
  --include='*.mjs' \
  --include='*.md' \
  --include='*.json' \
  '(reconciliation|reconcile|canonical.*identity|entity.*registry|identity.*registry|actor.*registry|agent.*registry|Matilda|Cade|Effie)' \
  server db routes client/src docs scripts \
  2>/dev/null || true

printf '\n=== NEIGHBORING PROJECT REPOSITORIES ===\n'
find /Users/marcela-dev/Projects \
  -mindepth 1 \
  -maxdepth 3 \
  -type d \
  -name .git \
  -print 2>/dev/null |
while read -r gitdir; do
  repo="${gitdir%/.git}"
  printf '\n--- %s ---\n' "$repo"
  git -C "$repo" rev-parse --abbrev-ref HEAD 2>/dev/null || true
  git -C "$repo" rev-parse --short=12 HEAD 2>/dev/null || true
done

printf '\n=== CROSS-REPOSITORY RECONCILIATION EVIDENCE ===\n'
find /Users/marcela-dev/Projects \
  -mindepth 1 \
  -maxdepth 3 \
  -type d \
  -name .git \
  -print 2>/dev/null |
while read -r gitdir; do
  repo="${gitdir%/.git}"

  matches="$(
    grep -RniE \
      --exclude-dir=.git \
      --exclude-dir=node_modules \
      --exclude-dir=dist \
      --exclude-dir=build \
      --include='*.ts' \
      --include='*.tsx' \
      --include='*.js' \
      --include='*.mjs' \
      --include='*.md' \
      --include='*.json' \
      '(reconciliation|canonical.*identity|entity.*registry|identity.*registry|actor.*registry|agent.*registry|\bMatilda\b|\bCade\b|\bEffie\b)' \
      "$repo" 2>/dev/null |
      head -300 || true
  )"

  if [ -n "$matches" ]; then
    printf '\n--- REPOSITORY: %s ---\n' "$repo"
    printf '%s\n' "$matches"
  fi
done

printf '\n=== AUTHORITY CLASSIFICATION BOUNDARY ===\n'
echo 'CURRENT_REPOSITORY_ASSUMED_AUTHORITATIVE=NO'
echo 'HISTORICAL_TIMELINE_ASSUMED_AUTHORITATIVE=NO'
echo 'AGENT_IDENTITY_INFERRED_FROM_COMPONENT_NAMES=NO'
echo 'MATILDA_EQUALS_CHIEF_OF_STAFF=NO'
echo 'IDENTITY_MUTATION_PERFORMED=NO'
echo 'GOVERNANCE_MUTATION_PERFORMED=NO'
echo 'RUNTIME_MUTATION_PERFORMED=NO'
echo 'DATABASE_MUTATION_PERFORMED=NO'
echo 'OBJECTIVE=IDENTIFY_REPOSITORY_THAT_OWNS_CURRENT_RECONCILIATION_ENTITY_CLASSIFICATION'

printf '\n=== FINAL WORKTREE ===\n'
git status --short
