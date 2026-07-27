import { FormEvent, useState } from "react";
import { useProjectContext } from "../project-context/useProjectContext";
import { useMatildaConversation } from "./useMatildaConversation";

export default function MatildaChatWorkspace() {
  const { registry, loading: projectLoading, error: projectError } =
    useProjectContext();

  const {
    activeProjectId,
    conversationId,
    turns,
    switching,
    submitting,
    requestError,
    sendMessage,
  } = useMatildaConversation();

  const [messagesByProject, setMessagesByProject] = useState<
    Record<string, string>
  >({});

  const message = activeProjectId
    ? messagesByProject[activeProjectId] ?? ""
    : "";

  const activeProjectLabel = projectLoading
    ? "Loading active project…"
    : projectError
      ? "Active project unavailable"
      : registry?.activeProject?.displayName ?? "No active project";

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    if (!activeProjectId) {
      return;
    }

    const sent = await sendMessage(message);

    if (sent) {
      setMessagesByProject((current) => ({
        ...current,
        [activeProjectId]: "",
      }));
    }
  }

  return (
    <section
      className="matilda-chat-workspace"
      data-shell-region="matilda-chat-workspace"
      aria-labelledby="matilda-chat-heading"
    >
      <header className="matilda-chat-workspace__header">
        <div>
          <p className="matilda-chat-workspace__eyebrow">Active workspace</p>
          <h1 id="matilda-chat-heading">Matilda</h1>
          <p className="matilda-chat-workspace__context">
            Project context: <strong>{activeProjectLabel}</strong>
          </p>
        </div>
      </header>

      <div
        className="matilda-chat-workspace__conversation"
        aria-live="polite"
      >
        {turns.length === 0 && !requestError && (
          <p className="matilda-chat-workspace__empty">
            Start a conversation with Matilda.
          </p>
        )}

        {turns.map((turn) => (
          <div key={turn.turn_id} className="matilda-chat-turn">
            <article className="matilda-chat-message matilda-chat-message--user">
              <span className="matilda-chat-message__author">You</span>
              <p>{turn.user_message}</p>
            </article>

            <article className="matilda-chat-message matilda-chat-message--matilda">
              <span className="matilda-chat-message__author">Matilda</span>
              <p>{turn.assistant_reply}</p>
            </article>
          </div>
        ))}

        {requestError && (
          <p className="matilda-chat-workspace__error" role="alert">
            {requestError}
          </p>
        )}
      </div>

      <form className="matilda-chat-composer" onSubmit={handleSubmit}>
        <label htmlFor="matilda-message">Message Matilda</label>
        <textarea
          id="matilda-message"
          rows={4}
          value={message}
          disabled={submitting || switching}
          onChange={(event) => {
            if (!activeProjectId) {
              return;
            }

            const nextMessage = event.target.value;

            setMessagesByProject((current) => ({
              ...current,
              [activeProjectId]: nextMessage,
            }));
          }}
          onKeyDown={(event) => {
            if (
              event.key === "Enter" &&
              !event.shiftKey &&
              !event.nativeEvent.isComposing
            ) {
              event.preventDefault();
              event.currentTarget.form?.requestSubmit();
            }
          }}
          placeholder="Describe what you want Matilda to help interpret…"
        />

        <div className="matilda-chat-composer__actions">
          <button
            type="submit"
            disabled={
              submitting ||
              switching ||
              !message.trim() ||
              !conversationId
            }
          >
            {submitting ? "Sending…" : "Send"}
          </button>
        </div>
      </form>
    </section>
  );
}
