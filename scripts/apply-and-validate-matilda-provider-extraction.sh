#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

ARCHIVE=""

for candidate in \
  "$REPO_ROOT/matilda-conversation-provider-extraction.zip" \
  "$HOME/Downloads/matilda-conversation-provider-extraction.zip" \
  "$HOME/Desktop/matilda-conversation-provider-extraction.zip"
do
  if [[ -f "$candidate" ]]; then
    ARCHIVE="$candidate"
    break
  fi
done

if [[ -z "$ARCHIVE" ]]; then
  printf 'STOP: matilda-conversation-provider-extraction.zip was not found.\n' >&2
  exit 1
fi

TARGET_FILES=(
  client/src/App.tsx
  client/src/matilda-chat/MatildaChatWorkspace.tsx
  client/src/matilda-chat/MatildaConversationProvider.tsx
  client/src/matilda-chat/useMatildaConversation.ts
)

EXPECTED_DELTA="$(printf '%s\n' "${TARGET_FILES[@]}" | sort)"

TMP="$(mktemp -d)"
EXTRACT="$TMP/extract"
BACKUP="$TMP/backup"
mkdir -p "$EXTRACT" "$BACKUP"

cleanup() {
  rm -rf "$TMP"
}
trap cleanup EXIT

snapshot() {
  {
    git diff --name-only
    git diff --cached --name-only
    git ls-files --others --exclude-standard
  } | sort -u
}

snapshot > "$TMP/before.txt"

unzip -q "$ARCHIVE" -d "$EXTRACT"

printf '\n=== APPLY REVIEWED FILES ===\n'

for file in "${TARGET_FILES[@]}"; do
  [[ -s "$EXTRACT/$file" ]] || {
    printf 'STOP: missing %s\n' "$file"
    exit 1
  }

  if [[ -f "$file" ]]; then
    mkdir -p "$BACKUP/$(dirname "$file")"
    cp "$file" "$BACKUP/$file"
  fi

  mkdir -p "$(dirname "$file")"
  cp "$EXTRACT/$file" "$file"
  printf 'APPLIED: %s\n' "$file"
done

rollback() {
  printf '\n=== ROLLBACK ===\n'
  for file in "${TARGET_FILES[@]}"; do
    if [[ -f "$BACKUP/$file" ]]; then
      cp "$BACKUP/$file" "$file"
      printf 'RESTORED: %s\n' "$file"
    else
      rm -f "$file"
      printf 'REMOVED: %s\n' "$file"
    fi
  done
}

snapshot > "$TMP/after-apply.txt"

comm -13 \
  "$TMP/before.txt" \
  "$TMP/after-apply.txt" \
  > "$TMP/delta.txt"

ACTUAL_DELTA="$(cat "$TMP/delta.txt")"

if [[ "$ACTUAL_DELTA" != "$EXPECTED_DELTA" ]]; then
  printf '\nSTOP: unauthorized implementation delta detected.\n'
  printf '\nExpected:\n%s\n' "$EXPECTED_DELTA"
  printf '\nActual:\n%s\n' "$ACTUAL_DELTA"
  rollback
  exit 1
fi

printf '\nPASS: implementation delta is correctly scoped.\n'

printf '\n=== DIFF CHECK ===\n'
git diff --check -- "${TARGET_FILES[@]}"

printf '\n=== CLIENT BUILD ===\n'
npm --prefix client run build

printf '\n=== MATILDA CONVERSATION LINEAGE TEST ===\n'
npx ts-node \
  --compiler-options '{"module":"CommonJS","moduleResolution":"Node"}' \
  db/matilda-conversation-lineage.test.ts

snapshot > "$TMP/final.txt"

comm -13 \
  "$TMP/before.txt" \
  "$TMP/final.txt" \
  > "$TMP/final-delta.txt"

FINAL_DELTA="$(cat "$TMP/final-delta.txt")"

if [[ "$FINAL_DELTA" != "$EXPECTED_DELTA" ]]; then
  printf '\nSTOP: validation introduced unexpected files.\n'
  rollback
  exit 1
fi

printf '\n=== SUCCESS ===\n'
printf 'Provider extraction validated successfully.\n'
printf 'Repository is ready for commit.\n'
