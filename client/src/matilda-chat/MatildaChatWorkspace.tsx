import { FormEvent, useEffect, useState } from "react";
import { useProjectContext } from "../project-context/useProjectContext";
import {
  getMatildaChatHistory,
  sendMatildaMessage,
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
  const submitting = activeProjectId
    ? submittingByProject[activeProjectId] ?? false
    : false;
  const requestError = activeProjectId
    ? errorsByProject[activeProjectId] ?? null
    : null;

  useEffect(() => {
    if (!activeProjectId) {
      return;
    }

    let cancelled = false;

    void getMatildaChatHistory(activeProjectId)
      .then((history) => {
        if (cancelled) {
          return;
        }

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
      });

      const persistedTurn: MatildaConversationTurn = {
        turn_id: `pending-${response.meta.interpretation_entry_id}`,
        project_id: projectId,
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
          disabled={submitting}
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
            disabled={submitting || !message.trim()}
          >
            {submitting ? "Sending…" : "Send"}
          </button>
        </div>
      </form>
    </section>
  );
}
