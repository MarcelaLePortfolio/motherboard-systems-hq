import { FormEvent, useEffect, useState } from "react";
import { useProjectContext } from "../project-context/useProjectContext";
import {
  createMatildaConversation,
  getMatildaChatHistory,
  getMatildaConversations,
  sendMatildaMessage,
  setActiveMatildaConversation,
  type MatildaConversationSummary,
  type MatildaConversationTurn,
} from "./matildaChatApi";

export default function MatildaChatWorkspace() {
  const { registry, loading: projectLoading, error: projectError } =
    useProjectContext();

  const [messagesByProject, setMessagesByProject] = useState<
    Record<string, string>
  >({});
  const [turnsByProject, setTurnsByProject] = useState<
    Record<string, MatildaConversationTurn[]>
  >({});
  const [conversationIdsByProject, setConversationIdsByProject] = useState<
    Record<string, string>
  >({});
  const [conversationsByProject, setConversationsByProject] = useState<
    Record<string, MatildaConversationSummary[]>
  >({});
  const [switchingByProject, setSwitchingByProject] = useState<
    Record<string, boolean>
  >({});
  const [submittingByProject, setSubmittingByProject] = useState<
    Record<string, boolean>
  >({});
  const [errorsByProject, setErrorsByProject] = useState<
    Record<string, string | null>
  >({});

  const activeProjectId = registry?.activeProjectId ?? null;
  const message = activeProjectId
    ? messagesByProject[activeProjectId] ?? ""
    : "";
  const turns = activeProjectId
    ? turnsByProject[activeProjectId] ?? []
    : [];
  const conversationId = activeProjectId
    ? conversationIdsByProject[activeProjectId] ?? null
    : null;
  const conversations = activeProjectId
    ? conversationsByProject[activeProjectId] ?? []
    : [];
  const submitting = activeProjectId
    ? submittingByProject[activeProjectId] ?? false
    : false;
  const switching = activeProjectId
    ? switchingByProject[activeProjectId] ?? false
    : false;
  const requestError = activeProjectId
    ? errorsByProject[activeProjectId] ?? null
    : null;

  useEffect(() => {
    if (!activeProjectId) {
      return;
    }

    let cancelled = false;

    void Promise.all([
      getMatildaConversations(activeProjectId),
      getMatildaChatHistory(activeProjectId),
    ])
      .then(([conversationState, history]) => {
        if (cancelled) {
          return;
        }

        setConversationsByProject((current) => ({
          ...current,
          [activeProjectId]: conversationState.conversations,
        }));
        setConversationIdsByProject((current) => ({
          ...current,
          [activeProjectId]: history.conversation_id,
        }));
        setTurnsByProject((current) => ({
          ...current,
          [activeProjectId]: history.turns,
        }));
      })
      .catch((error) => {
        if (!cancelled) {
          setErrorsByProject((current) => ({
            ...current,
            [activeProjectId]:
              error instanceof Error
                ? error.message
                : "Unable to load Matilda chat history",
          }));
        }
      });

    return () => {
      cancelled = true;
    };
  }, [activeProjectId]);

  const activeProjectLabel = projectLoading
    ? "Loading active project…"
    : projectError
      ? "Active project unavailable"
      : registry?.activeProject?.displayName ?? "No active project";

  async function handleCreateConversation() {
    const projectId = registry?.activeProjectId;

    if (!projectId || switchingByProject[projectId]) {
      return;
    }

    setSwitchingByProject((current) => ({
      ...current,
      [projectId]: true,
    }));
    setErrorsByProject((current) => ({
      ...current,
      [projectId]: null,
    }));

    try {
      const response = await createMatildaConversation(projectId);

      setConversationsByProject((current) => ({
        ...current,
        [projectId]: response.conversations,
      }));
      setConversationIdsByProject((current) => ({
        ...current,
        [projectId]: response.conversation.conversation_id,
      }));
      setTurnsByProject((current) => ({
        ...current,
        [projectId]: [],
      }));
      setMessagesByProject((current) => ({
        ...current,
        [projectId]: "",
      }));
    } catch (error) {
      setErrorsByProject((current) => ({
        ...current,
        [projectId]:
          error instanceof Error
            ? error.message
            : "Unable to create Matilda conversation",
      }));
    } finally {
      setSwitchingByProject((current) => ({
        ...current,
        [projectId]: false,
      }));
    }
  }

  async function handleSwitchConversation(nextConversationId: string) {
    const projectId = registry?.activeProjectId;

    if (
      !projectId ||
      !nextConversationId ||
      nextConversationId === conversationIdsByProject[projectId] ||
      switchingByProject[projectId]
    ) {
      return;
    }

    setSwitchingByProject((current) => ({
      ...current,
      [projectId]: true,
    }));
    setErrorsByProject((current) => ({
      ...current,
      [projectId]: null,
    }));

    try {
      const response = await setActiveMatildaConversation(
        projectId,
        nextConversationId
      );
      const history = await getMatildaChatHistory(projectId);

      setConversationsByProject((current) => ({
        ...current,
        [projectId]: response.conversations,
      }));
      setConversationIdsByProject((current) => ({
        ...current,
        [projectId]: history.conversation_id,
      }));
      setTurnsByProject((current) => ({
        ...current,
        [projectId]: history.turns,
      }));
    } catch (error) {
      setErrorsByProject((current) => ({
        ...current,
        [projectId]:
          error instanceof Error
            ? error.message
            : "Unable to switch Matilda conversation",
      }));
    } finally {
      setSwitchingByProject((current) => ({
        ...current,
        [projectId]: false,
      }));
    }
  }

  async function handleSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();

    const trimmedMessage = message.trim();

    if (!trimmedMessage || submitting) {
      return;
    }

    const projectId = registry?.activeProjectId;

    if (!projectId) {
      return;
    }

    const activeConversationId =
      conversationIdsByProject[projectId] ?? null;

    if (!activeConversationId) {
      setErrorsByProject((current) => ({
        ...current,
        [projectId]: "Matilda conversation is still loading.",
      }));
      return;
    }

    setSubmittingByProject((current) => ({
      ...current,
      [projectId]: true,
    }));
    setErrorsByProject((current) => ({
      ...current,
      [projectId]: null,
    }));

    try {

      const response = await sendMatildaMessage({
        message: trimmedMessage,
        projectId,
        conversationId: activeConversationId,
      });

      const persistedTurn: MatildaConversationTurn = {
        turn_id: `pending-${response.meta.interpretation_entry_id}`,
        project_id: projectId,
        conversation_id: activeConversationId,
        user_message: response.message,
        assistant_reply: response.reply,
        interpretation_entry_id: response.meta.interpretation_entry_id,
        created_at: response.meta.timestamp,
      };

      setTurnsByProject((current) => ({
        ...current,
        [projectId]: [
          ...(current[projectId] ?? []),
          persistedTurn,
        ],
      }));
      setMessagesByProject((current) => ({
        ...current,
        [projectId]: "",
      }));
    } catch (error) {
      setErrorsByProject((current) => ({
        ...current,
        [projectId]:
          error instanceof Error
            ? error.message
            : "Unknown Matilda chat error",
      }));
    } finally {
      setSubmittingByProject((current) => ({
        ...current,
        [projectId]: false,
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

        <div className="matilda-chat-workspace__thread-controls">
          <label htmlFor="matilda-conversation-select">
            Conversation
          </label>
          <select
            id="matilda-conversation-select"
            value={conversationId ?? ""}
            disabled={!activeProjectId || switching || submitting}
            onChange={(event) => {
              void handleSwitchConversation(event.target.value);
            }}
          >
            {conversations.map((conversation) => (
              <option
                key={conversation.conversation_id}
                value={conversation.conversation_id}
              >
                {conversation.title}
              </option>
            ))}
          </select>
          <button
            type="button"
            disabled={!activeProjectId || switching || submitting}
            onClick={() => {
              void handleCreateConversation();
            }}
          >
            {switching ? "Loading…" : "New conversation"}
          </button>
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
          <div key={turn.turn_id}>
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
