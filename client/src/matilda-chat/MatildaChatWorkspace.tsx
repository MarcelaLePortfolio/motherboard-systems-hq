import { FormEvent, useState } from "react";
import { useProjectContext } from "../project-context/useProjectContext";
import {
  sendMatildaMessage,
  type MatildaChatResponse,
} from "./matildaChatApi";

export default function MatildaChatWorkspace() {
  const { registry, loading: projectLoading, error: projectError } =
    useProjectContext();

  const [message, setMessage] = useState("");
  const [result, setResult] = useState<MatildaChatResponse | null>(null);
  const [submitting, setSubmitting] = useState(false);
  const [requestError, setRequestError] = useState<string | null>(null);

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

    setSubmitting(true);
    setRequestError(null);

    try {
      const response = await sendMatildaMessage(trimmedMessage);
      setResult(response);
      setMessage("");
    } catch (error) {
      setRequestError(
        error instanceof Error ? error.message : "Unknown Matilda chat error"
      );
    } finally {
      setSubmitting(false);
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
        {!result && !requestError && (
          <p className="matilda-chat-workspace__empty">
            Start a conversation with Matilda.
          </p>
        )}

        {result && (
          <>
            <article className="matilda-chat-message matilda-chat-message--user">
              <span className="matilda-chat-message__author">You</span>
              <p>{result.message}</p>
            </article>

            <article className="matilda-chat-message matilda-chat-message--matilda">
              <span className="matilda-chat-message__author">Matilda</span>
              <p>{result.reply}</p>
            </article>
          </>
        )}

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
          onChange={(event) => setMessage(event.target.value)}
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
