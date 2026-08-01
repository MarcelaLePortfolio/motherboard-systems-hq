import { useMatildaConversation } from "../matilda-chat/useMatildaConversation";

export type ShellWorkspace =
  | "dashboard"
  | "chat"
  | "packages"
  | "approvals";

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

  const controlsDisabled = loading || switching;

  async function handleCreateConversation() {
    const created = await createConversation();

    if (created) {
      onSelectWorkspace("chat");
    }
  }

  async function handleSelectConversation(
    nextConversationId: string,
  ) {
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
          aria-current={
            activeWorkspace === "dashboard"
              ? "page"
              : undefined
          }
          onClick={() =>
            onSelectWorkspace("dashboard")
          }
        >
          Dashboard
        </button>

        <button
          type="button"
          aria-current={
            activeWorkspace === "packages"
              ? "page"
              : undefined
          }
          onClick={() =>
            onSelectWorkspace("packages")
          }
        >
          Packages
        </button>

        <button
          type="button"
          aria-current={
            activeWorkspace === "approvals"
              ? "page"
              : undefined
          }
          onClick={() =>
            onSelectWorkspace("approvals")
          }
        >
          Approvals
        </button>
      </section>

      <section
        className="shell-navigation-section shell-conversation-navigation"
        aria-labelledby="shell-navigation-conversations"
      >
        <div className="shell-conversation-navigation__heading">
          <h2 id="shell-navigation-conversations">
            Conversations
          </h2>

          <button
            type="button"
            className="shell-conversation-navigation__new"
            disabled={controlsDisabled}
            onClick={() =>
              void handleCreateConversation()
            }
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
                conversation.conversation_id ===
                conversationId;

              return (
                <button
                  key={conversation.conversation_id}
                  type="button"
                  className="shell-conversation-navigation__item"
                  data-active={
                    active ? "" : undefined
                  }
                  aria-current={
                    active ? "page" : undefined
                  }
                  disabled={controlsDisabled}
                  onClick={() =>
                    void handleSelectConversation(
                      conversation.conversation_id,
                    )
                  }
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
        <h2 id="shell-navigation-departments">
          Departments
        </h2>
        <p>
          Department navigation is intentionally deferred.
        </p>
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
