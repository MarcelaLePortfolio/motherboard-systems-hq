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

printf '\n=== ARCHIVE ===\n%s\n' "$ARCHIVE"

printf '\n=== ARTIFACT SCOPE ===\n'
if [[ "$ACTUAL_FILES" != "$EXPECTED_FILES" ]]; then
  printf 'STOP: archive contents do not match the authorized six-file artifact scope.\n'
  printf '\nExpected:\n%s\n' "$EXPECTED_FILES"
  printf '\nActual:\n%s\n' "$ACTUAL_FILES"
  exit 1
fi
printf 'PASS: archive contains only the four implementation files and two diffs.\n'

printf '\n=== APP DIFF CONSISTENCY ===\n'
diff -u \
  client/src/App.tsx \
  "$REVIEW_ROOT/client/src/App.tsx" \
  > "$REVIEW_ROOT/generated-App.tsx.diff" || true

if ! diff -u \
  "$REVIEW_ROOT/diffs/App.tsx.diff" \
  "$REVIEW_ROOT/generated-App.tsx.diff"
then
  printf 'STOP: supplied App.tsx diff does not match the supplied final file.\n'
  exit 1
fi
printf 'PASS: App.tsx diff matches the final artifact.\n'

printf '\n=== WORKSPACE DIFF CONSISTENCY ===\n'
diff -u \
  client/src/matilda-chat/MatildaChatWorkspace.tsx \
  "$REVIEW_ROOT/client/src/matilda-chat/MatildaChatWorkspace.tsx" \
  > "$REVIEW_ROOT/generated-MatildaChatWorkspace.tsx.diff" || true

if ! diff -u \
  "$REVIEW_ROOT/diffs/MatildaChatWorkspace.tsx.diff" \
  "$REVIEW_ROOT/generated-MatildaChatWorkspace.tsx.diff"
then
  printf 'STOP: supplied MatildaChatWorkspace.tsx diff does not match the supplied final file.\n'
  exit 1
fi
printf 'PASS: MatildaChatWorkspace.tsx diff matches the final artifact.\n'

printf '\n=== REQUIRED PROVIDER BOUNDARIES ===\n'

grep -Fq 'useProjectContext' \
  "$REVIEW_ROOT/client/src/matilda-chat/MatildaConversationProvider.tsx"

grep -Fq 'getMatildaConversations' \
  "$REVIEW_ROOT/client/src/matilda-chat/MatildaConversationProvider.tsx"

grep -Fq 'getMatildaChatHistory' \
  "$REVIEW_ROOT/client/src/matilda-chat/MatildaConversationProvider.tsx"

grep -Fq 'createMatildaConversation' \
  "$REVIEW_ROOT/client/src/matilda-chat/MatildaConversationProvider.tsx"

grep -Fq 'setActiveMatildaConversation' \
  "$REVIEW_ROOT/client/src/matilda-chat/MatildaConversationProvider.tsx"

grep -Fq 'sendMatildaMessage' \
  "$REVIEW_ROOT/client/src/matilda-chat/MatildaConversationProvider.tsx"

grep -Fq 'persistedTurn.project_id !== projectId' \
  "$REVIEW_ROOT/client/src/matilda-chat/MatildaConversationProvider.tsx"

grep -Fq 'persistedTurn.conversation_id !== activeConversationId' \
  "$REVIEW_ROOT/client/src/matilda-chat/MatildaConversationProvider.tsx"

grep -Fq 'persistedTurn.interpretation_entry_id !==' \
  "$REVIEW_ROOT/client/src/matilda-chat/MatildaConversationProvider.tsx"

grep -Fq '<MatildaConversationProvider>' \
  "$REVIEW_ROOT/client/src/App.tsx"

grep -Fq '<ProjectContextProvider>' \
  "$REVIEW_ROOT/client/src/App.tsx"

grep -Fq 'useMatildaConversation' \
  "$REVIEW_ROOT/client/src/matilda-chat/MatildaChatWorkspace.tsx"

printf 'PASS: project scope, authoritative persisted-turn checks, provider nesting, and hook consumption are present.\n'

printf '\n=== PROHIBITED SCOPE CHECKS ===\n'

if grep -RniE \
  'NavigationRegion|shell\.css|MissionDashboardWorkspace' \
  "$REVIEW_ROOT/client/src/matilda-chat/MatildaConversationProvider.tsx" \
  "$REVIEW_ROOT/client/src/matilda-chat/useMatildaConversation.ts"
then
  printf 'STOP: new provider files contain unexpected shell coupling.\n'
  exit 1
fi

if grep -RniE \
  'pending-|synthetic turn|Date\.now\(\).*turn' \
  "$REVIEW_ROOT/client/src"
then
  printf 'STOP: artifact appears to introduce synthetic client turn identity.\n'
  exit 1
fi

printf 'PASS: no sidebar coupling or synthetic-turn pattern detected.\n'

printf '\n=== BOOLEAN ACTION SIGNATURES ===\n'
grep -nE \
  'createConversation:|sendMessage:' \
  "$REVIEW_ROOT/client/src/matilda-chat/MatildaConversationProvider.tsx"

printf '\nREVIEW RESULT: ARTIFACT PASSES STATIC ARCHITECTURAL REVIEW.\n'
printf 'No repository implementation files were changed.\n'
printf 'The next bounded step is application plus local build and lineage validation.\n'
