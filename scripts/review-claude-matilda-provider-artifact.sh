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
  printf 'Place it in the repository root, Downloads, or Desktop, then rerun this script.\n' >&2
  exit 1
fi

REVIEW_ROOT="$(mktemp -d)"
trap 'rm -rf "$REVIEW_ROOT"' EXIT

unzip -q "$ARCHIVE" -d "$REVIEW_ROOT"

EXPECTED_FILES="$(printf '%s\n' \
  client/src/App.tsx \
  client/src/matilda-chat/MatildaChatWorkspace.tsx \
  client/src/matilda-chat/MatildaConversationProvider.tsx \
  client/src/matilda-chat/useMatildaConversation.ts \
  diffs/App.tsx.diff \
  diffs/MatildaChatWorkspace.tsx.diff \
  | sort)"

ACTUAL_FILES="$(
  cd "$REVIEW_ROOT"
  find . -type f -print \
    | sed 's#^\./##' \
    | sort
)"

APP_FILE="$REVIEW_ROOT/client/src/App.tsx"
WORKSPACE_FILE="$REVIEW_ROOT/client/src/matilda-chat/MatildaChatWorkspace.tsx"
PROVIDER_FILE="$REVIEW_ROOT/client/src/matilda-chat/MatildaConversationProvider.tsx"
HOOK_FILE="$REVIEW_ROOT/client/src/matilda-chat/useMatildaConversation.ts"

printf '\n=== ARCHIVE ===\n%s\n' "$ARCHIVE"

printf '\n=== ARTIFACT SCOPE ===\n'
if [[ "$ACTUAL_FILES" != "$EXPECTED_FILES" ]]; then
  printf 'STOP: archive contents do not match the authorized six-file artifact scope.\n'
  printf '\nExpected:\n%s\n' "$EXPECTED_FILES"
  printf '\nActual:\n%s\n' "$ACTUAL_FILES"
  exit 1
fi
printf 'PASS: archive contains only the four implementation files and two informational diffs.\n'

printf '\n=== FINAL FILE PRESENCE ===\n'
for required_file in \
  "$APP_FILE" \
  "$WORKSPACE_FILE" \
  "$PROVIDER_FILE" \
  "$HOOK_FILE"
do
  if [[ ! -s "$required_file" ]]; then
    printf 'STOP: required implementation file is missing or empty: %s\n' "$required_file"
    exit 1
  fi
done
printf 'PASS: all four implementation files are present and non-empty.\n'

printf '\n=== INFORMATIONAL CODE DIFFS ===\n'
printf '\n--- App.tsx code changes ---\n'
diff -u \
  --label client/src/App.tsx \
  --label client/src/App.tsx \
  client/src/App.tsx \
  "$APP_FILE" \
  | sed '1,2d' || true

printf '\n--- MatildaChatWorkspace.tsx code changes ---\n'
diff -u \
  --label client/src/matilda-chat/MatildaChatWorkspace.tsx \
  --label client/src/matilda-chat/MatildaChatWorkspace.tsx \
  client/src/matilda-chat/MatildaChatWorkspace.tsx \
  "$WORKSPACE_FILE" \
  | sed '1,2d' || true

printf '\nNOTE: supplied unified-diff headers are intentionally not treated as authoritative because paths and timestamps differ across environments.\n'

printf '\n=== PROVIDER PLACEMENT ===\n'
grep -Fq 'ProjectContextProvider' "$APP_FILE"
grep -Fq 'MatildaConversationProvider' "$APP_FILE"

PROJECT_LINE="$(grep -n '<ProjectContextProvider>' "$APP_FILE" | head -n 1 | cut -d: -f1)"
CONVERSATION_LINE="$(grep -n '<MatildaConversationProvider>' "$APP_FILE" | head -n 1 | cut -d: -f1)"
SHELL_LINE="$(grep -n '<Shell' "$APP_FILE" | head -n 1 | cut -d: -f1)"

if [[ -z "$PROJECT_LINE" || -z "$CONVERSATION_LINE" || -z "$SHELL_LINE" ]]; then
  printf 'STOP: required provider or shell mount could not be located in App.tsx.\n'
  exit 1
fi

if ! (( PROJECT_LINE < CONVERSATION_LINE && CONVERSATION_LINE < SHELL_LINE )); then
  printf 'STOP: provider nesting order is incorrect.\n'
  exit 1
fi
printf 'PASS: MatildaConversationProvider is mounted inside ProjectContextProvider and above Shell.\n'

printf '\n=== SHARED CONVERSATION BOUNDARY ===\n'
grep -Fq 'useProjectContext' "$PROVIDER_FILE"
grep -Eq 'activeProject(Id)?' "$PROVIDER_FILE"
grep -Fq 'createContext' "$PROVIDER_FILE"
grep -Fq 'useContext' "$HOOK_FILE"
grep -Fq 'useMatildaConversation' "$WORKSPACE_FILE"

if grep -Eq 'useState<[^>]*(Conversation|MatildaConversation)' "$WORKSPACE_FILE"; then
  printf 'STOP: MatildaChatWorkspace still appears to own conversation lifecycle state.\n'
  exit 1
fi

printf 'PASS: project-aware conversation lifecycle is exposed through a shared context and consumed by the workspace hook.\n'

printf '\n=== CONVERSATION OPERATIONS ===\n'
for operation in \
  getMatildaConversations \
  getMatildaChatHistory \
  createMatildaConversation \
  setActiveMatildaConversation \
  sendMatildaMessage
do
  if ! grep -Fq "$operation" "$PROVIDER_FILE"; then
    printf 'STOP: provider is missing required conversation operation: %s\n' "$operation"
    exit 1
  fi
done
printf 'PASS: list, history, create, activate, and send operations remain in the provider lifecycle.\n'

printf '\n=== AUTHORITATIVE TURN SAFETY ===\n'
for field in \
  project_id \
  conversation_id \
  interpretation_entry_id
do
  if ! grep -Fq "$field" "$PROVIDER_FILE"; then
    printf 'STOP: provider does not reference required persisted-turn field: %s\n' "$field"
    exit 1
  fi
done

if grep -RniE \
  'pending-|synthetic[[:space:]_-]*turn|Date\.now\(\).*(turn|message)|crypto\.randomUUID\(\).*(turn|message)' \
  "$REVIEW_ROOT/client/src"
then
  printf 'STOP: artifact appears to introduce synthetic client-side turn identity.\n'
  exit 1
fi
printf 'PASS: persisted project, conversation, and interpretation identity checks remain represented, with no synthetic-turn pattern detected.\n'

printf '\n=== SHELL COUPLING BOUNDARY ===\n'
if grep -RniE \
  'NavigationRegion|shell\.css|MissionDashboardWorkspace|WorkspaceMount' \
  "$PROVIDER_FILE" \
  "$HOOK_FILE"
then
  printf 'STOP: conversation provider or hook contains unexpected shell/sidebar coupling.\n'
  exit 1
fi
printf 'PASS: provider and hook remain independent of sidebar and shell rendering concerns.\n'

printf '\n=== BOOLEAN ACTION CONTRACT ===\n'
grep -nE \
  'createConversation|sendMessage' \
  "$PROVIDER_FILE" \
  "$HOOK_FILE" \
  "$WORKSPACE_FILE" \
  | head -n 40

if ! grep -Eq 'Promise<boolean>|=>[[:space:]]*boolean' "$PROVIDER_FILE" "$HOOK_FILE"; then
  printf 'STOP: expected boolean success contract was not found in the provider boundary.\n'
  exit 1
fi
printf 'PASS: boolean success signaling is explicit at the provider boundary and remains available for local draft clearing.\n'

printf '\n=== STATIC ARCHITECTURAL REVIEW RESULT ===\n'
printf 'PASS: the Claude artifact satisfies the bounded provider-extraction architecture review.\n'
printf 'No repository implementation files were changed.\n'
printf 'The next safe step is a separate application-and-validation command that copies only these four files, builds the client, and runs the existing Matilda lineage test before commit.\n'
