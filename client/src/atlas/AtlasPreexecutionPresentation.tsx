import { useEffect, useState } from "react";
import { useMatildaConversation } from "../matilda-chat/useMatildaConversation";
import {
  getAtlasPreexecution,
  type AtlasPreexecutionResponse,
} from "./atlasPreexecutionApi";

export default function AtlasPreexecutionPresentation() {
  const { activeProjectId, conversationId } = useMatildaConversation();
  const [result, setResult] = useState<AtlasPreexecutionResponse | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;

    setResult(null);
    setError(null);

    if (!activeProjectId || !conversationId) {
      setLoading(false);
      return () => {
        cancelled = true;
      };
    }

    setLoading(true);

    void getAtlasPreexecution(activeProjectId, conversationId)
      .then((nextResult) => {
        if (!cancelled) {
          setResult(nextResult);
        }
      })
      .catch((nextError) => {
        if (!cancelled) {
          setError(
            nextError instanceof Error
              ? nextError.message
              : "Unable to load Atlas pre-execution observations.",
          );
        }
      })
      .finally(() => {
        if (!cancelled) {
          setLoading(false);
        }
      });

    return () => {
      cancelled = true;
    };
  }, [activeProjectId, conversationId]);

  return (
    <aside
      className="atlas-preexecution-presentation"
      data-shell-region="atlas-preexecution"
      aria-labelledby="atlas-preexecution-heading"
    >
      <header className="atlas-preexecution-presentation__header">
        <p className="atlas-preexecution-presentation__eyebrow">
          Read-only observation
        </p>
        <h2 id="atlas-preexecution-heading">Atlas pre-execution</h2>
      </header>

      {!activeProjectId || !conversationId ? (
        <p className="atlas-preexecution-presentation__status">
          Select an active conversation to view Atlas observations.
        </p>
      ) : null}

      {loading ? (
        <p className="atlas-preexecution-presentation__status">
          Loading Atlas observations…
        </p>
      ) : null}

      {error ? (
        <p className="atlas-preexecution-presentation__error" role="status">
          {error}
        </p>
      ) : null}

      {!loading && !error && result ? (
        <div className="atlas-preexecution-presentation__content">
          <p>
            {result.observations.length === 0
              ? "No pre-execution observations are available for this conversation."
              : `${result.observations.length} pre-execution observation${
                  result.observations.length === 1 ? "" : "s"
                } available.`}
          </p>

          {result.observations.length > 0 ? (
            <ol className="atlas-preexecution-presentation__observations">
              {result.observations.map((observation, index) => (
                <li
                  key={`${observation.sourceKind ?? "observation"}-${
                    observation.sourceId ?? index
                  }`}
                >
                  <pre>{JSON.stringify(observation, null, 2)}</pre>
                </li>
              ))}
            </ol>
          ) : null}
        </div>
      ) : null}
    </aside>
  );
}
