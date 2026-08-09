#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== DETERMINISTIC EVIDENCE REQUEST SIGNAL INVESTIGATION ==="

echo
echo "=== CURRENT EXPLANATION REQUEST SIGNAL ==="
cat server/matilda-explanation-request-signal.ts
echo
cat server/matilda-explanation-request-signal.test.ts

echo
echo "=== CURRENT WORKFLOW SIGNAL CONSUMPTION ==="
sed -n '150,195p' server/matilda-chat-workflow.ts

echo
echo "=== CURRENT PROJECT-CONTEXT RETRIEVAL + SUPPORT SEAMS ==="
rg -n -C 8 \
'projectContextExcerpts|projectContextRetrieval|supportSourceReferences|evidenceSufficient' \
server/matilda-chat-workflow.ts \
scripts/utils/ollamaChat.ts

echo
echo "=== OBSERVED LIVE FAILURE ==="
cat <<'OBSERVED'
The support-driven Source-Excerpt implementation is structurally green.

When Ollama selects a validated project_context_excerpt in
supportSourceReferences, deterministic runtime construction produces the exact
Source-Excerpt artifact correctly.

However, repeated live runs of the same explicit repository-evidence request
have produced both:

A.
supportSourceReferences:
  project_context_excerpt + conversation_turn

and:

B.
supportSourceReferences:
  conversation_turn only

Therefore the remaining nondeterminism is semantic source selection, not
Source-Excerpt construction.

Do not retry the same model-selection hypothesis.
OBSERVED

echo
echo "=== INVESTIGATION REQUEST ==="
cat <<'QUESTION'
Investigate whether Evidence Composition should use a dedicated deterministic
Evidence Request Signal rather than relying on the semantic model to decide
whether project-context evidence should be surfaced.

The signal must remain narrowly bounded.

Evaluate whether the repository supports introducing:

isExplicitEvidenceRequest(message: string): boolean

with semantics limited to direct requests such as:

- "What evidence supports that?"
- "What repository evidence supports that?"
- "What repository evidence shows that?"
- "Show me the repository evidence."
- "What evidence do we have in the repository?"

The signal must NOT classify:

- generic "why" questions;
- ordinary explanation requests;
- "tell me more";
- implementation requests;
- unrelated questions containing the word evidence.

Determine:

1. Can Evidence Request classification be deterministic before Ollama invocation?

2. Can it remain separate from the existing Explanation Request Signal rather
   than broadening that signal's established ontology?

3. When the request is explicitly for repository evidence, can validated
   project-context excerpts already retrieved for that invocation be admitted
   into Source-Excerpt presentation deterministically?

4. Would doing so constitute evidence presentation rather than semantic
   authorship, given that the workflow would reproduce exact retrieved excerpts?

5. Must deterministic admission still require repository retrieval to have
   actually returned matching project-context excerpts?

6. Can the semantic reply remain entirely Matilda-authored while evidence
   presentation is deterministic?

7. Can supportSourceReferences preserve its existing semantic provenance role
   without being repurposed as the trigger for explicit evidence presentation?

8. Can evidenceSufficient preserve its existing meaning?

9. Does this solve the observed repeated-live-run nondeterminism without another
   Ollama invocation or prompt-only enforcement?

Return exactly one classification:

DETERMINISTIC_EVIDENCE_REQUEST_SIGNAL_READY
EVIDENCE_REQUEST_SIGNAL_NEEDS_MORE_EVIDENCE
DETERMINISTIC_EVIDENCE_REQUEST_SIGNAL_NOT_SAFE

If READY, identify exactly one smallest implementation unit.

Do not implement.
Do not close Evidence Composition.
Do not modify the existing Explanation Request Signal.
Do not begin Boundary Composition.
Do not begin Adaptive Detail Selection.
Use repository evidence only.
QUESTION

echo
echo "=== BASELINE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
