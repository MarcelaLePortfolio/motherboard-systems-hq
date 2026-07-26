#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

printf '\n=== BRANCH AND STATUS ===\n'
git branch --show-current
git status --short

printf '\n=== NAVIGATION REGION ===\n'
sed -n '1,320p' client/src/shell/NavigationRegion.tsx

printf '\n=== SHELL ===\n'
sed -n '1,320p' client/src/shell/Shell.tsx

printf '\n=== WORKSPACE MOUNT ===\n'
sed -n '1,320p' client/src/shell/WorkspaceMount.tsx

printf '\n=== PLACEHOLDER WORKSPACE ===\n'
sed -n '1,260p' client/src/shell/PlaceholderWorkspace.tsx 2>/dev/null || true

printf '\n=== SHELL CSS ===\n'
sed -n '1,520p' client/src/shell/shell.css

printf '\n=== MATILDA CHAT WORKSPACE ===\n'
sed -n '1,360p' client/src/matilda-chat/MatildaChatWorkspace.tsx

printf '\n=== CONVERSATION COMPONENTS ===\n'
find client/src \
  -maxdepth 4 \
  -type f \
  \( -iname '*conversation*' -o -iname '*thread*' \) \
  | sort

printf '\n=== CONVERSATION REFERENCES ===\n'
grep -RniE \
'conversationId|conversation_id|activeConversation|MatildaConversation|conversationThreads|list.*Conversation' \
client/src \
--exclude-dir=node_modules \
--exclude-dir=dist \
| head -320 || true
