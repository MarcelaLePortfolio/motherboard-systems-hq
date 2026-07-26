#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

NAV_FILE="client/src/shell/NavigationRegion.tsx"
CSS_FILE="client/src/shell/shell.css"
BACKUP_DIR=".sidebar-conversation-backup"

rollback() {
  printf '\n=== ROLLBACK ===\n'

  if [[ -f "$BACKUP_DIR/NavigationRegion.tsx" ]]; then
    cp "$BACKUP_DIR/NavigationRegion.tsx" "$NAV_FILE"
  fi

  if [[ -f "$BACKUP_DIR/shell.css" ]]; then
    cp "$BACKUP_DIR/shell.css" "$CSS_FILE"
  fi

  printf 'RESTORED: sidebar implementation files.\n'
}

trap 'status=$?; if [[ $status -ne 0 ]]; then rollback; fi; exit $status' EXIT

printf '\n=== AUTHORIZED FILE CHECK ===\n'

EXPECTED_FILES="$(
  printf '%s\n' \
    "$NAV_FILE" \
    "$CSS_FILE" \
  | sort
)"

ACTUAL_FILES="$(
  git diff --name-only -- \
    "$NAV_FILE" \
    "$CSS_FILE" \
  | sort
)"

if [[ "$ACTUAL_FILES" != "$EXPECTED_FILES" ]]; then
  printf 'STOP: expected exactly two implementation files.\n'
  printf '\nExpected:\n%s\n' "$EXPECTED_FILES"
  printf '\nActual:\n%s\n' "$ACTUAL_FILES"
  exit 1
fi

printf 'PASS: implementation is limited to NavigationRegion and shell.css.\n'

printf '\n=== SEMANTIC BOUNDARY CHECK ===\n'

grep -q 'useMatildaConversation' "$NAV_FILE"
grep -q 'conversationId' "$NAV_FILE"
grep -q 'createConversation' "$NAV_FILE"
grep -q 'switchConversation' "$NAV_FILE"
grep -q 'aria-current={active ? "page" : undefined}' "$NAV_FILE"
grep -q 'Sidebar conversation consumer slice' "$CSS_FILE"

if git diff --name-only -- \
  client/src/matilda-chat/MatildaConversationProvider.tsx \
  client/src/matilda-chat/MatildaChatWorkspace.tsx \
  client/src/matilda-chat/matildaChatApi.ts \
  routes \
  db \
  | grep -q .; then
  printf 'STOP: protected lifecycle or runtime files changed.\n'
  exit 1
fi

printf 'PASS: provider, workspace selector, APIs, routes, and runtime are unchanged.\n'

printf '\n=== DIFF SAFETY CHECK ===\n'
git diff --check -- "$NAV_FILE" "$CSS_FILE"
printf 'PASS: scoped diff contains no whitespace errors.\n'

printf '\n=== CLIENT BUILD ===\n'
npm --prefix client run build
printf 'PASS: client build completed.\n'

printf '\n=== MATILDA CONVERSATION LINEAGE TEST ===\n'
npx ts-node \
  --compiler-options '{"module":"CommonJS","moduleResolution":"Node"}' \
  db/matilda-conversation-lineage.test.ts
printf 'PASS: Matilda conversation lineage test completed.\n'

printf '\n=== FINAL SCOPE RECHECK ===\n'

FINAL_FILES="$(
  git diff --name-only -- \
    "$NAV_FILE" \
    "$CSS_FILE" \
  | sort
)"

if [[ "$FINAL_FILES" != "$EXPECTED_FILES" ]]; then
  printf 'STOP: validation altered the authorized implementation scope.\n'
  exit 1
fi

trap - EXIT
rm -rf "$BACKUP_DIR"

printf '\n=== SIDEBAR CONVERSATION CONSUMER RESULT ===\n'
printf 'PASS: sidebar consumes the shared conversation provider.\n'
printf 'PASS: active conversation selection is wired.\n'
printf 'PASS: new-conversation creation is wired.\n'
printf 'PASS: workspace selector remains for duplicate-view validation.\n'
