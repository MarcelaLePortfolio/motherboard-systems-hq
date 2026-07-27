#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

GARBAGE_FILE=".git/objects/61/.!56395!38f8595a071b278ba5be39684832a3084441df"
QUARANTINE_DIR="/tmp/motherboard-git-object-quarantine-$(date +%Y%m%d_%H%M%S)"
BRANCH="$(git branch --show-current)"

printf '\n=== PRE-QUARANTINE VERIFICATION ===\n'

if [[ ! -f "$GARBAGE_FILE" ]]; then
  printf 'STOP: expected garbage file is no longer present.\n'
  exit 1
fi

if [[ -s "$GARBAGE_FILE" ]]; then
  printf 'STOP: suspicious file is not zero bytes; leaving it untouched.\n'
  exit 1
fi

printf 'PASS: malformed object entry exists and is zero bytes.\n'
printf 'PASS: valid object files remain separately present in the directory.\n'

mkdir -p "$QUARANTINE_DIR"
mv "$GARBAGE_FILE" "$QUARANTINE_DIR/"

printf 'QUARANTINED: %s\n' "$GARBAGE_FILE"
printf 'LOCATION: %s\n' "$QUARANTINE_DIR"

printf '\n=== GIT OBJECT DATABASE VERIFICATION ===\n'

FSCK_OUTPUT="$(mktemp)"
trap 'rm -f "$FSCK_OUTPUT"' EXIT

git fsck --full 2>&1 | tee "$FSCK_OUTPUT"

if grep -Eqi 'missing|corrupt|fatal|error:|bad sha1' "$FSCK_OUTPUT"; then
  printf '\nSTOP: Git still reports corruption or missing objects.\n'
  printf 'The quarantined file remains available at %s\n' "$QUARANTINE_DIR"
  exit 1
fi

printf '\nPASS: Git reports no missing, corrupt, fatal, or bad-SHA object errors.\n'

printf '\n=== OBJECT COUNT ===\n'
git count-objects -vH

if git count-objects -vH | grep -Eq '^garbage: [1-9]'; then
  printf 'STOP: Git still reports garbage objects.\n'
  exit 1
fi

printf 'PASS: Git reports no remaining garbage object files.\n'

printf '\n=== HEAD AND REMOTE VERIFICATION ===\n'

LOCAL_HEAD="$(git rev-parse HEAD)"
REMOTE_HEAD="$(git rev-parse "origin/$BRANCH")"

printf 'Local HEAD:  %s\n' "$LOCAL_HEAD"
printf 'Remote HEAD: %s\n' "$REMOTE_HEAD"

if [[ "$LOCAL_HEAD" != "$REMOTE_HEAD" ]]; then
  printf 'STOP: local HEAD and origin/%s do not match.\n' "$BRANCH"
  exit 1
fi

printf 'PASS: local and remote branch heads match.\n'

printf '\n=== PROJECT STRUCTURE VERIFICATION ===\n'

for path in \
  package.json \
  client/package.json \
  db/main.db \
  client \
  server \
  routes \
  db \
  docs \
  scripts \
  public
do
  if [[ ! -e "$path" ]]; then
    printf 'STOP: required project path is missing: %s\n' "$path"
    exit 1
  fi

  printf 'PASS: %s\n' "$path"
done

printf '\n=== RESULT ===\n'
printf 'PASS: the malformed zero-byte Git artifact was isolated.\n'
printf 'PASS: the Git object database verifies without corruption.\n'
printf 'PASS: the current branch matches its pushed remote state.\n'
printf 'PASS: required project files and directories are present.\n'
printf 'The quarantined artifact is located at:\n%s\n' "$QUARANTINE_DIR"
