#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== BOUNDARY COMPOSITION — PRE-REPLY ADMISSION SEAM ==="

echo
echo "=== CURRENT CONTEXT COMPOSITION PATH ==="
rg -n -C 8 \
'projectContextRetrieval|composeMatildaConversationContext|projectContextExcerpts|selectedHistory|ollamaChat' \
server/matilda-chat-workflow.ts \
server/matilda-conversation-context-runtime.ts \
server/matilda-project-context-retrieval.ts \
scripts/utils/ollamaChat.ts

echo
echo "=== PROJECT CONTEXT RETRIEVAL IMPLEMENTATION ==="
sed -n '1,280p' server/matilda-project-context-retrieval.ts

echo
echo "=== CONVERSATION CONTEXT COMPOSITION ==="
sed -n '1,320p' server/matilda-conversation-context-runtime.ts

echo
echo "=== PROJECT CONTEXT TESTS ==="
for file in \
  server/matilda-project-context-retrieval.test.ts \
  server/matilda-conversation-context-runtime.test.ts
do
  if [[ -f "$file" ]]; then
    echo
    echo "--- $file ---"
    cat "$file"
  fi
done

echo
echo "=== RELEVANCE / RANKING / ADMISSION REFERENCES ==="
rg -n -C 6 \
'relevance|relevant|ranking|ranked|score|scored|admission|admit|selection|selected|project context|context excerpt' \
server \
scripts \
docs/architecture \
--glob='*.ts' \
--glob='*.md' \
--glob='*.sh' \
| head -n 420 || true

echo
echo "=== ESTABLISHED FAILURE ==="
cat <<'FAILURE'
Boundary Composition behavioral evidence establishes:

1. Material boundaries are generally preserved.

2. An immaterial deferred-work statement was surfaced in response to:
   "What does this test verify?"

3. Adding the bounded instruction:
   "Do not surface boundaries, deferred work, or unresolved limits that do not
   materially affect the immediate conclusion or requested answer."
   did not change that behavior.

4. Therefore prompt-only omission is not behaviorally reliable enough to close
   Boundary Composition.

5. Post-model filtering is not authorized because determining semantic
   materiality after generation could alter Matilda-authored meaning.

The next question is whether the repository already has a bounded pre-reply
context relevance/admission seam that can solve this without beginning a new
Adaptive Detail Selection architecture.
FAILURE

echo
echo "=== INVESTIGATION REQUEST ==="
cat <<'QUESTION'
Investigate repository evidence only.

Determine:

1. Does retrieveMatildaProjectContext(...) already score, rank, filter, or
   otherwise select project-context excerpts based on the current user message?

2. If yes:
   - what exact relevance signal does it use;
   - what does that signal currently own;
   - is the selected project-context set already intended to represent context
     relevant to the current request?

3. Does composeMatildaConversationContext(...) perform any further
   project-context admission or only preserve the retrieval result?

4. Does ollamaChat currently receive every retrieved projectContextExcerpt
   unchanged?

5. Is there any existing deterministic or semantic signal that distinguishes:
   - context needed to support the immediate requested answer;
   - context that is merely colocated in the same excerpt;
   - deferred or boundary content that is irrelevant to that answer?

6. In the failed immaterial-boundary scenario, is the problem primarily that:
   a. the entire mixed excerpt is admitted because retrieval operates at excerpt
      granularity;
   b. Matilda ignores an already-existing relevance signal;
   c. context selection does not exist;
   d. the test fixture itself creates an artificial mixed-content excerpt that
      production retrieval would normally split or rank differently?

7. Would solving this require changing project-context retrieval/ranking itself?

8. If yes, would that work semantically belong to the already-deferred Adaptive
   Detail Selection/context-composition corridor rather than Boundary
   Composition?

9. Is there a smaller existing seam inside Boundary Composition that can prevent
   immaterial disclosure without:
   - filtering Matilda-authored reply text;
   - adding another model invocation;
   - adding more prompt synonyms;
   - introducing Boundary Status;
   - changing retrieval semantics?

Return exactly one classification:

BOUNDARY_EXISTING_PRE_REPLY_ADMISSION_SEAM_READY
BOUNDARY_MIXED_EXCERPT_FIXTURE_ARTIFACT
BOUNDARY_BLOCKED_BY_CONTEXT_SELECTION
BOUNDARY_PRE_REPLY_ADMISSION_NOT_READY

Then identify exactly one smallest next investigation or implementation unit.

Do not implement.
Do not modify project-context retrieval.
Do not begin Adaptive Detail Selection implementation.
Do not modify Evidence Composition.
Do not add another prompt instruction.
Do not add post-model semantic filtering.
Do not add Boundary Status or a structured Boundary artifact.
Preserve one user message -> one workflow -> one Ollama invocation.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
