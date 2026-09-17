#!/usr/bin/env bash
set -euo pipefail

BRANCH="feature/support-source-references-runtime"
BASELINE="4df267cf1"

git fetch origin "$BRANCH"
test "$(git rev-parse --abbrev-ref HEAD)" = "$BRANCH"
test "$(git rev-parse --short=9 HEAD)" = "$BASELINE"
test "$(git rev-parse --short=9 "origin/$BRANCH")" = "$BASELINE"
test -z "$(git diff --cached --name-only)"

python3 - << 'PY'
from pathlib import Path

path = Path("client/src/atlas/atlasPreexecutionApi.ts")
text = path.read_text()

old = """export interface AtlasPreexecutionResponse {
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
"""

new = """export interface AtlasPreexecutionResponse {
  status: "ok";
  route: "atlas_preexecution_read_route";
  projectId: string;
  observations: AtlasPreexecutionObservation[];
  lineageSequences: unknown[];
  causalExplanation: false;
  executionHistory: false;
  approvalDecision: false;
  authorityDecision: false;
}
"""

if old not in text:
    raise SystemExit(
        "Expected Atlas response interface not found; refusing speculative edit."
    )

path.write_text(text.replace(old, new, 1))
PY

printf '\n===== REPAIRED CLIENT CONTRACT =====\n'
cat client/src/atlas/atlasPreexecutionApi.ts

printf '\n===== SERVER CONTRACT =====\n'
sed -n '71,108p' server/routes/atlas/preexecution.ts

printf '\n===== RESPONSE CONTRACT CHECK =====\n'
if grep -nE \
  '^[[:space:]]*conversationId:[[:space:]]*string;' \
  client/src/atlas/atlasPreexecutionApi.ts
then
  echo "CLIENT_RESPONSE_CONTRACT=FAILED"
  exit 1
fi
echo "CLIENT_RESPONSE_CONTRACT=ALIGNED"

printf '\n===== READ-ONLY BOUNDARY =====\n'
if grep -RniE \
  'method:[[:space:]]*"(POST|PUT|PATCH|DELETE)"|createMatildaConversation|setActiveMatildaConversation|sendMatildaMessage' \
  client/src/atlas
then
  echo "READ_ONLY_BOUNDARY=FAILED"
  exit 1
fi
echo "READ_ONLY_BOUNDARY=PASSED"

printf '\n===== TYPESCRIPT DIAGNOSTIC =====\n'
DIAGNOSTIC="$(cd client && npx tsc --noEmit --pretty false 2>&1 || true)"
printf '%s\n' "$DIAGNOSTIC"

ATLAS_SHELL_ERRORS="$(
  printf '%s\n' "$DIAGNOSTIC" |
    grep -E 'src/atlas/|src/shell/Shell\.tsx' || true
)"

if test -n "$ATLAS_SHELL_ERRORS"; then
  echo "ATLAS_SHELL_TYPESCRIPT=FAILED"
  printf '%s\n' "$ATLAS_SHELL_ERRORS"
  exit 1
fi
echo "ATLAS_SHELL_TYPESCRIPT=PASSED"

printf '\n===== KNOWN EXTERNAL BUILD BLOCKER =====\n'
printf '%s\n' "$DIAGNOSTIC" | \
  grep -E 'src/approvals/ApprovalsWorkspace\.tsx.*TS6133' || true

printf '\n===== AUTHORIZED TARGET STATUS =====\n'
git status --short -- \
  client/src/atlas/atlasPreexecutionApi.ts \
  client/src/atlas/AtlasPreexecutionPresentation.tsx \
  client/src/shell/Shell.tsx \
  client/src/shell/shell.css

printf '\n===== AUTHORIZED TARGET DIFF =====\n'
git diff -- \
  client/src/atlas/atlasPreexecutionApi.ts \
  client/src/atlas/AtlasPreexecutionPresentation.tsx \
  client/src/shell/Shell.tsx \
  client/src/shell/shell.css

git add \
  client/src/atlas/atlasPreexecutionApi.ts \
  client/src/atlas/AtlasPreexecutionPresentation.tsx \
  client/src/shell/Shell.tsx \
  client/src/shell/shell.css

git commit -m "Add Atlas read-only pre-execution presentation"
git push origin "$BRANCH"
