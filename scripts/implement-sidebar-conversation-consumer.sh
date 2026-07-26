#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel)"
cd "$REPO_ROOT"

NAV_FILE="client/src/shell/NavigationRegion.tsx"
CSS_FILE="client/src/shell/shell.css"
BACKUP_ROOT="$(mktemp -d)"
VALIDATED=0

cleanup() {
  rm -rf "$BACKUP_ROOT"
}

rollback() {
  printf '\n=== ROLLBACK ===\n'
  cp "$BACKUP_ROOT/NavigationRegion.tsx" "$NAV_FILE"
  cp "$BACKUP_ROOT/shell.css" "$CSS_FILE"
  printf 'RESTORED: %s\n' "$NAV_FILE"
  printf 'RESTORED: %s\n' "$CSS_FILE"
}

on_exit() {
  status=$?

  if [[ $status -ne 0 && $VALIDATED -eq 0 ]]; then
    rollback
  fi

  cleanup
  exit "$status"
}

trap on_exit EXIT

cp "$NAV_FILE" "$BACKUP_ROOT/NavigationRegion.tsx"
cp "$CSS_FILE" "$BACKUP_ROOT/shell.css"

cat > "$NAV_FILE" << 'NAVIGATION_EOF'
import { useMatildaConversation } from "../matilda-chat/useMatildaConversation";

export type ShellWorkspace = "dashboard" | "chat";

type NavigationRegionProps = {
  activeWorkspace: ShellWorkspace;
  onSelectWorkspace: (workspace: ShellWorkspace) => void;
};

export default function NavigationRegion({
  activeWorkspace,
  onSelectWorkspace,
}: NavigationRegionProps) {
  const {
    conversationId,
    conversations,
    loading,
    switching,
    requestError,
    createConversation,
    switchConversation,
  } = useMatildaConversation();

  const conversationControlsDisabled = loading || switching;

  async function handleCreateConversation() {
    const created = await createConversation();

    if (created) {
      onSelectWorkspace("chat");
    }
  }

  async function handleSelectConversation(nextConversationId: string) {
    onSelectWorkspace("chat");
    await switchConversation(nextConversationId);
  }

  return (
    <nav
      className="shell-navigation-region"
      data-shell-region="navigation"
      aria-label="Primary navigation"
    >
      <section
        className="shell-navigation-section"
        aria-labelledby="shell-navigation-primary"
      >
        <h2 id="shell-navigation-primary">Workspace</h2>

        <button
          type="button"
          aria-current={activeWorkspace === "dashboard" ? "page" : undefined}
          onClick={() => onSelectWorkspace("dashboard")}
        >
          Dashboard
        </button>

        <button
          type="button"
          aria-current={activeWorkspace === "chat" ? "page" : undefined}
          onClick={() => onSelectWorkspace("chat")}
        >
          Chats
        </button>
      </section>

      <section
        className="shell-navigation-section shell-conversation-navigation"
        aria-labelledby="shell-navigation-conversations"
      >
        <div className="shell-conversation-navigation__heading">
          <h2 id="shell-navigation-conversations">Conversations</h2>

          <button
            type="button"
            className="shell-conversation-navigation__new"
            disabled={conversationControlsDisabled}
            onClick={() => {
              void handleCreateConversation();
            }}
          >
            {switching ? "Working…" : "New"}
          </button>
        </div>

        {loading && conversations.length === 0 ? (
          <p className="shell-conversation-navigation__status">
            Loading conversations…
          </p>
        ) : null}

        {!loading && conversations.length === 0 ? (
          <p className="shell-conversation-navigation__status">
            No conversations yet.
          </p>
        ) : null}

        {conversations.length > 0 ? (
          <div
            className="shell-conversation-navigation__list"
            aria-label="Matilda conversations"
          >
            {conversations.map((conversation) => {
              const active =
                conversation.conversation_id === conversationId;

              return (
                <button
                  key={conversation.conversation_id}
                  type="button"
                  className="shell-conversation-navigation__item"
                  data-active={active ? "" : undefined}
                  aria-current={active ? "page" : undefined}
                  disabled={conversationControlsDisabled}
                  onClick={() => {
                    void handleSelectConversation(
                      conversation.conversation_id
                    );
                  }}
                >
                  <span className="shell-conversation-navigation__title">
                    {conversation.title}
                  </span>
                </button>
              );
            })}
          </div>
        ) : null}

        {requestError ? (
          <p
            className="shell-conversation-navigation__error"
            role="status"
          >
            {requestError}
          </p>
        ) : null}
      </section>

      <section
        className="shell-navigation-section"
        aria-labelledby="shell-navigation-departments"
      >
        <h2 id="shell-navigation-departments">Departments</h2>
        <p>Department navigation is intentionally deferred.</p>
      </section>

      <section
        className="shell-navigation-section"
        aria-labelledby="shell-navigation-system"
      >
        <h2 id="shell-navigation-system">System</h2>
        <p>Diagnostics is intentionally deferred.</p>
      </section>
    </nav>
  );
}
NAVIGATION_EOF

python3 << 'PY'
from pathlib import Path

path = Path("client/src/shell/shell.css")
text = path.read_text()
marker = "/* Sidebar conversation consumer slice */"

if marker in text:
    raise SystemExit("STOP: sidebar conversation styles already exist.")

addition = r'''

/* Sidebar conversation consumer slice */
.shell-navigation-section {
  display: grid;
  gap: 0.5rem;
}

.shell-conversation-navigation {
  min-width: 0;
}

.shell-conversation-navigation__heading {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
}

.shell-conversation-navigation__heading h2 {
  margin: 0;
}

.shell-conversation-navigation__new {
  flex: 0 0 auto;
}

.shell-conversation-navigation__list {
  display: grid;
  gap: 0.375rem;
  min-width: 0;
}

.shell-conversation-navigation__item {
  width: 100%;
  min-width: 0;
  text-align: left;
}

.shell-conversation-navigation__item[data-active] {
  font-weight: 700;
  outline: 2px solid currentColor;
  outline-offset: -2px;
}

.shell-conversation-navigation__title {
  display: block;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.shell-conversation-navigation__status,
.shell-conversation-navigation__error {
  margin: 0;
  font-size: 0.875rem;
}

.shell-conversation-navigation__error {
  overflow-wrap: anywhere;
}
'''

path.write_text(text.rstrip() + addition + "\n")
PY

printf '\n=== AUTHORIZED FILE CHECK ===\n'

CHANGED_SCOPE="$(
  git diff --name-only -- "$NAV_FILE" "$CSS_FILE" | sort
)"

EXPECTED_SCOPE="$(
  printf '%s\n' "$NAV_FILE" "$CSS_FILE" | sort
)"

if [[ "$CHANGED_SCOPE" != "$EXPECTED_SCOPE" ]]; then
  printf 'STOP: sidebar implementation did not produce the expected two-file change.\n'
  printf '\nExpected:\n%s\n' "$EXPECTED_SCOPE"
  printf '\nActual:\n%s\n' "$CHANGED_SCOPE"
  exit 1
fi

printf 'PASS: implementation is limited to NavigationRegion and shell styles.\n'

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
  printf 'STOP: protected conversation lifecycle or runtime files changed.\n'
  exit 1
fi

printf 'PASS: provider, workspace selector, APIs, routes, and runtime remain unchanged.\n'

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

FINAL_SCOPE="$(
  git diff --name-only -- "$NAV_FILE" "$CSS_FILE" | sort
)"

if [[ "$FINAL_SCOPE" != "$EXPECTED_SCOPE" ]]; then
  printf 'STOP: validation changed the authorized implementation scope.\n'
  exit 1
fi

VALIDATED=1

printf '\n=== SIDEBAR CONVERSATION CONSUMER RESULT ===\n'
printf 'PASS: sidebar now consumes the shared conversation provider.\n'
printf 'PASS: active conversation selection and new-conversation actions are wired.\n'
printf 'PASS: the workspace selector remains available for duplicate-view validation.\n'
