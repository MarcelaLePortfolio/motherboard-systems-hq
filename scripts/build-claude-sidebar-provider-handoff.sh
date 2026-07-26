#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

HANDOFF_ROOT="_claude_handoff/sidebar-conversation-provider-extraction"
ARCHIVE="_claude_handoff/sidebar-conversation-provider-extraction-minimal.zip"

rm -rf "$HANDOFF_ROOT"
rm -f "$ARCHIVE"

mkdir -p \
  "$HANDOFF_ROOT/client/src/matilda-chat" \
  "$HANDOFF_ROOT/client/src/project-context" \
  "$HANDOFF_ROOT/client/src/shell" \
  "$HANDOFF_ROOT/docs/architecture"

REQUIRED_FILES=(
  "client/src/App.tsx"
  "client/src/matilda-chat/MatildaChatWorkspace.tsx"
  "client/src/matilda-chat/matildaChatApi.ts"
  "client/src/project-context/ProjectContextProvider.tsx"
  "client/src/project-context/ProjectContextControl.tsx"
  "client/src/project-context/useProjectContext.ts"
  "client/src/shell/NavigationRegion.tsx"
  "client/src/shell/Shell.tsx"
  "client/src/shell/WorkspaceMount.tsx"
  "client/src/shell/shell.css"
  "docs/architecture/SIDEBAR_CONVERSATION_STATE_EXTRACTION_PLAN_2026-07-25.md"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$file" ]]; then
    printf 'STOP: required handoff file is missing: %s\n' "$file" >&2
    exit 1
  fi

  mkdir -p "$HANDOFF_ROOT/$(dirname "$file")"
  cp "$file" "$HANDOFF_ROOT/$file"
done

while IFS= read -r file; do
  relative_path="${file#client/src/project-context/}"
  destination="$HANDOFF_ROOT/client/src/project-context/$relative_path"

  if [[ ! -f "$destination" ]]; then
    cp "$file" "$destination"
  fi
done < <(
  find client/src/project-context \
    -maxdepth 1 \
    -type f \
    \( -name '*.ts' -o -name '*.tsx' \) \
    | sort
)

cat > "$HANDOFF_ROOT/CLAUDE_TASK.md" << 'TASK_EOF'
# Claude Task — Shared Matilda Conversation Provider Extraction

Perform one bounded client-side refactor.

## Objective

Extract the existing project-scoped Matilda conversation lifecycle from `MatildaChatWorkspace` into one shared React provider and hook so the sidebar and workspace can later consume the same authoritative state.

## Required implementation

Add:

- `client/src/matilda-chat/MatildaConversationProvider.tsx`
- `client/src/matilda-chat/useMatildaConversation.ts`

Move the existing conversation lifecycle into that provider:

- project-scoped conversation loading
- active conversation identity
- active conversation turns
- conversation list
- loading and switching state
- submission state
- request error
- create-conversation action
- switch-conversation action
- send-message action

Update the smallest necessary existing files so:

- the provider is mounted inside the existing `ProjectContextProvider` boundary
- `MatildaChatWorkspace` consumes the new hook
- the current conversation selector remains in the workspace header
- current visible behavior remains as close as possible to unchanged

## Hard boundaries

Do not:

- move the conversation selector into the sidebar yet
- redesign or restyle the sidebar
- add hard-coded conversations
- duplicate conversation state
- change backend routes, schemas, persistence, or API contracts
- weaken project-scoped conversation identity
- create synthetic turns
- change authoritative persisted-turn lineage validation
- modify files outside this bundle unless an import path absolutely requires it

## Deliverable format

Return:

1. a concise explanation of the state ownership change
2. the complete contents of every new or modified file
3. the exact validation commands to run
4. any assumption that could not be verified from this bundle

Do not request the full repository.
TASK_EOF

cat > "$HANDOFF_ROOT/FILE_MANIFEST.txt" << 'MANIFEST_EOF'
client/src/App.tsx
client/src/matilda-chat/MatildaChatWorkspace.tsx
client/src/matilda-chat/matildaChatApi.ts
client/src/project-context/*
client/src/shell/NavigationRegion.tsx
client/src/shell/Shell.tsx
client/src/shell/WorkspaceMount.tsx
client/src/shell/shell.css
docs/architecture/SIDEBAR_CONVERSATION_STATE_EXTRACTION_PLAN_2026-07-25.md
CLAUDE_TASK.md
MANIFEST_EOF

(
  cd "_claude_handoff"
  zip -qr "sidebar-conversation-provider-extraction-minimal.zip" \
    "sidebar-conversation-provider-extraction"
)

printf '\n=== CLAUDE HANDOFF CREATED ===\n'
printf 'Folder:  %s\n' "$HANDOFF_ROOT"
printf 'Archive: %s\n' "$ARCHIVE"
printf '\n=== ARCHIVE CONTENTS ===\n'
unzip -l "$ARCHIVE"
printf '\nUpload only this archive to Claude:\n%s\n' "$ARCHIVE"

git add scripts/build-claude-sidebar-provider-handoff.sh
git commit -m "chore: add minimal Claude sidebar provider handoff"
git push origin feature/new-ui-shell
