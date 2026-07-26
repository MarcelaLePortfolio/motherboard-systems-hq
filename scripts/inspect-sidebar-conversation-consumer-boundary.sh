#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

FILES=(
  client/src/matilda-chat/MatildaConversationProvider.tsx
  client/src/matilda-chat/useMatildaConversation.ts
  client/src/matilda-chat/MatildaChatWorkspace.tsx
  client/src/shell/NavigationRegion.tsx
  client/src/shell/Shell.tsx
  client/src/shell/WorkspaceMount.tsx
  client/src/shell/shell.css
)

printf '\n=== SIDEBAR CONVERSATION CONSUMER BOUNDARY ===\n'
printf 'This inspection is read-only.\n'
printf 'No repository files will be modified.\n'

printf '\n=== REPOSITORY STATE ===\n'
git status --short

printf '\nBranch: '
git branch --show-current

printf 'HEAD: '
git rev-parse --short HEAD

printf '\n=== REQUIRED FILES ===\n'

for file in "${FILES[@]}"; do
    if [[ ! -f "$file" ]]; then
        printf 'STOP: missing %s\n' "$file"
        exit 1
    fi
    printf 'FOUND: %s\n' "$file"
done

printf '\n=== PROVIDER API ===\n'

grep -nE \
'createConversation|switchConversation|sendMessage|activeConversation|activeConversationId|conversations|turns|loading|error' \
client/src/matilda-chat/MatildaConversationProvider.tsx \
client/src/matilda-chat/useMatildaConversation.ts \
|| true

printf '\n=== CURRENT PROVIDER CONSUMERS ===\n'

grep -RIn \
--exclude-dir=node_modules \
--exclude-dir=dist \
'useMatildaConversation' \
client/src \
|| true

printf '\n=== WORKSPACE CONVERSATION UI ===\n'

grep -nE \
'conversation|Conversation|New Conversation|createConversation|switchConversation|select|option' \
client/src/matilda-chat/MatildaChatWorkspace.tsx \
|| true

printf '\n=== NAVIGATION REGION ===\n'
sed -n '1,240p' client/src/shell/NavigationRegion.tsx

printf '\n=== SHELL ===\n'
sed -n '1,240p' client/src/shell/Shell.tsx

printf '\n=== WORKSPACE MOUNT ===\n'
sed -n '1,240p' client/src/shell/WorkspaceMount.tsx

printf '\n=== SIDEBAR CSS ===\n'

grep -nE \
'navigation|sidebar|thread|conversation|active|button|nav' \
client/src/shell/shell.css \
|| true

printf '\n=== IMPLEMENTATION BOUNDARY ===\n'
printf '%s\n' \
'✓ Sidebar consumes useMatildaConversation().' \
'✓ Sidebar renders conversation list.' \
'✓ Sidebar calls switchConversation().' \
'✓ Sidebar calls createConversation().' \
'✓ Active conversation is highlighted.' \
'✓ Workspace remains unchanged during first implementation slice.' \
'✓ Selector removal occurs only after sidebar validation.'

printf '\n=== INSPECTION COMPLETE ===\n'
printf 'Review output before authorizing sidebar implementation.\n'
