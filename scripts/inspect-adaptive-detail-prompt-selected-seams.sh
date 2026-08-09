#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== INSPECT ADAPTIVE DETAIL — PROMPT + SELECTED SEGMENTS SEAMS ==="

if [[ "$(git rev-parse --short HEAD)" != "ae1fb4e2" ]]; then
  echo "STOP: HEAD no longer matches reconciliation checkpoint ae1fb4e2."
  exit 2
fi

unexpected="$(
  git status --porcelain |
  grep -vE '^\?\? scripts/inspect-adaptive-detail-prompt-selected-seams\.sh$' ||
  true
)"

if [[ -n "$unexpected" ]]; then
  echo "STOP: unexpected working-tree changes exist:"
  printf '%s\n' "$unexpected"
  exit 2
fi

echo
echo "=== STRUCTURED RESPONSE TYPE + SCHEMA ==="
sed -n '1,210p' scripts/utils/ollamaChat.ts

echo
echo "=== STRUCTURED RESPONSE PARSER ==="
sed -n '186,420p' scripts/utils/ollamaChat.ts

echo
echo "=== PROMPT ASSEMBLY ==="
sed -n '420,610p' scripts/utils/ollamaChat.ts

echo
echo "=== POST-MODEL VALIDATION ==="
sed -n '610,780p' scripts/utils/ollamaChat.ts

echo
echo "=== SEGMENT CANDIDATE TYPE + CALL SITES ==="
grep -n -A35 -B15 \
  -E 'OllamaChatProjectContextSegmentCandidate|projectContextSegmentCandidates' \
  scripts/utils/ollamaChat.ts \
  server/matilda-chat-workflow.ts \
  server/matilda-conversation-context-runtime.ts

echo
echo "=== CURRENT STRUCTURED CONTRACT TESTS ==="
for file in \
  scripts/utils/ollamaChat.test.ts \
  scripts/utils/ollamaChat.support-source-references.test.ts \
  scripts/utils/ollamaChat.support-source-production.test.ts \
  scripts/utils/ollamaChat.structured-evidence-object.test.ts \
  scripts/utils/ollamaChat.boundary-composition.test.ts
do
  echo
  echo "--- $file ---"
  sed -n '1,360p' "$file"
done

cat <<'QUESTIONS'

Inspect only. Do not implement.

Confirm the exact smallest edit seams for:

1. OllamaStructuredResponse.selectedContextSegments.

2. OLLAMA_CHAT_OUTPUT_SCHEMA required selectedContextSegments array.

3. Selection item schema:
   relativePath
   sourceStartLine
   sourceEndLine

4. parseStructuredResponse malformed selection failure.

5. Exact-selection identity validation against supplied
   projectContextSegmentCandidates.

6. Deterministic duplicate removal.

7. Prompt serialization of segment candidates using only:
   Segment source: relativePath:start-end
   Authority status: candidate_evidence_not_authority
   text

8. Whether parentRelativePath and parentLineNumber can remain omitted from
   prompt serialization while remaining available for deterministic validation.

9. Prompt instructions clearly distinguishing:
   - parent excerpts = support provenance / evidence universe
   - child segments = semantic-materiality candidate universe

10. Prompt instruction requiring Matilda to list exactly the child segments
    materially used for project-context response composition.

11. [] validity when no project context is materially needed.

12. Conversation history remaining independently usable.

13. Project-context support consistency validation:
    when a support reference points to a parent for which supplied child
    candidates exist, at least one selected child must carry that exact
    parentRelativePath + parentLineNumber.

14. Failure behavior for inconsistent project support:
    fail closed; never silently mutate selection or support.

15. Explicit evidence behavior remaining untouched.

16. evidenceSufficient remaining based on validated support references.

17. Whether selectedContextSegments needs to be returned from OllamaChatResult
    for runtime behavior, or can remain internal after validation.

18. Smallest test additions needed for:
    - prompt serialization;
    - valid exact selection;
    - [];
    - malformed selection;
    - unsupplied selection;
    - duplicate selection;
    - support/selection consistency;
    - conversation support independence;
    - explicit-evidence regression;
    - one invocation invariant.

Return exactly one classification:

ADAPTIVE_DETAIL_PROMPT_SELECTED_SEAMS_READY
ADAPTIVE_DETAIL_PROMPT_SELECTED_SEAMS_NEED_RECONCILIATION
ADAPTIVE_DETAIL_PROMPT_SELECTED_SEAMS_NOT_READY

Then identify exactly one next implementation unit.

Do not edit production files.
Do not edit tests.
Do not serialize candidates.
Do not add selectedContextSegments.
Do not modify supportSourceReferences.
Do not modify evidenceSufficient.
Do not modify Evidence Composition.
Do not persist selection.
Do not add another model invocation.
Do not perform post-model semantic filtering.
