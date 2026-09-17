#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="4df267cf1"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

mkdir -p client/src/atlas

cat > client/src/atlas/atlasPreexecutionApi.ts << 'TS'
export interface AtlasPreexecutionObservation {
  sourceKind?: string;
  sourceId?: string;
  observation?: string;
  [key: string]: unknown;
}

export interface AtlasPreexecutionResponse {
  projectId: string;
  conversationId: string;
  observations: AtlasPreexecutionObservation[];
  lineageSequences?: unknown[];
  causalExplanation: false;
  executionHistory: false;
  approvalDecision: false;
  authorityDecision: false;
  [key: string]: unknown;
}

export async function getAtlasPreexecution(
  projectId: string,
  conversationId: string,
): Promise<AtlasPreexecutionResponse> {
  const params = new URLSearchParams({
    projectId,
    conversationId,
  });

  const response = await fetch(`/atlas/preexecution?${params.toString()}`, {
    method: "GET",
    headers: {
      Accept: "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(
      `Unable to load Atlas pre-execution observations (${response.status}).`,
    );
  }

  return (await response.json()) as AtlasPreexecutionResponse;
}
TS

cat > client/src/atlas/AtlasPreexecutionPresentation.tsx << 'TSX'
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
TSX

python3 - << 'PY'
from pathlib import Path

path = Path("client/src/shell/Shell.tsx")
text = path.read_text()

import_line = 'import AtlasPreexecutionPresentation from "../atlas/AtlasPreexecutionPresentation";\n'
anchor = 'import ProjectContextControl from "../project-context/ProjectContextControl";\n'

if import_line not in text:
    if anchor not in text:
        raise SystemExit("Shell import anchor not found")
    text = text.replace(anchor, anchor + import_line, 1)

old = '        <WorkspaceMount activeWorkspace={activeWorkspace} />\n'
new = (
    '        <div className="shell-workspace-stack">\n'
    '          <WorkspaceMount activeWorkspace={activeWorkspace} />\n'
    '          <AtlasPreexecutionPresentation />\n'
    '        </div>\n'
)

if old not in text:
    raise SystemExit("Shell workspace mount anchor not found")

text = text.replace(old, new, 1)
path.write_text(text)
PY

cat >> client/src/shell/shell.css << 'CSS'

.shell-workspace-stack {
  min-width: 0;
  display: grid;
  gap: 1rem;
}

.atlas-preexecution-presentation {
  border: 1px solid currentColor;
  border-radius: 0.75rem;
  padding: 1rem;
}

.atlas-preexecution-presentation__header {
  margin-bottom: 0.75rem;
}

.atlas-preexecution-presentation__eyebrow,
.atlas-preexecution-presentation__status,
.atlas-preexecution-presentation__error,
.atlas-preexecution-presentation__content p {
  margin: 0;
}

.atlas-preexecution-presentation__eyebrow {
  font-size: 0.75rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.atlas-preexecution-presentation__header h2 {
  margin: 0.25rem 0 0;
}

.atlas-preexecution-presentation__error {
  font-weight: 600;
}

.atlas-preexecution-presentation__observations {
  margin: 0.75rem 0 0;
  padding-left: 1.5rem;
}

.atlas-preexecution-presentation__observations pre {
  overflow-x: auto;
  white-space: pre-wrap;
  overflow-wrap: anywhere;
}
CSS

printf '\n===== IMPLEMENTATION DIFF =====\n'
git diff -- client/src/atlas client/src/shell/Shell.tsx client/src/shell/shell.css

printf '\n===== BUILD =====\n'
if test -f client/package.json; then
  (cd client && npm run build)
else
  npm run build
fi

printf '\n===== READ-ONLY BOUNDARY =====\n'
if grep -RniE \
  'method:[[:space:]]*"(POST|PUT|PATCH|DELETE)"|createMatildaConversation|setActiveMatildaConversation|sendMatildaMessage' \
  client/src/atlas
then
  echo "Unexpected mutation-capable Atlas client reference detected."
  exit 1
fi

git add \
  client/src/atlas/atlasPreexecutionApi.ts \
  client/src/atlas/AtlasPreexecutionPresentation.tsx \
  client/src/shell/Shell.tsx \
  client/src/shell/shell.css

git commit -m "Add Atlas read-only pre-execution presentation"
git push origin "$BRANCH"
