#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

cat <<'FINDINGS'
DETERMINISTIC_EVIDENCE_REQUEST_SIGNAL_READY

Repository-supported findings:

1. Evidence Request classification can be deterministic before the Ollama
   invocation because the workflow already performs deterministic message
   classification before calling ollamaChat.

2. A dedicated Evidence Request Signal can remain separate from the existing
   Explanation Request Signal. The existing explanation classifier has a
   bounded ontology and explicitly rejects:
   "What evidence do we have in the repository?"

3. Project-context retrieval already occurs before the Ollama invocation and
   before response composition:
   retrieveMatildaProjectContext(...)
   -> composeMatildaConversationContext(...)
   -> ollamaChat(...)

4. Therefore an explicit repository-evidence request can be classified
   deterministically after retrieval is available and before semantic
   generation occurs.

5. Deterministic Source-Excerpt admission must remain bounded to actual
   projectContextExcerpts supplied by repository retrieval for the current
   invocation. It must never invent or reconstruct an excerpt.

6. Reproducing an exact retrieved excerpt is evidence presentation rather than
   semantic authorship. The deterministic layer selects no new proposition and
   writes no explanatory evidence text.

7. The semantic reply can remain entirely Matilda-authored. No second model
   invocation is required.

8. supportSourceReferences can preserve its existing role as model-selected
   semantic support provenance. It does not need to become the trigger for
   explicit repository-evidence presentation.

9. evidenceSufficient must preserve its existing meaning and derivation from
   validated supportSourceReferences. A deterministic Evidence Request Signal
   must not silently redefine evidenceSufficient.

10. The observed live nondeterminism is specifically that identical explicit
    repository-evidence requests may or may not cause Ollama to select the
    available project_context_excerpt in supportSourceReferences.

11. A deterministic Evidence Request Signal removes that presentation trigger
    from stochastic semantic source selection while preserving semantic
    authorship and the one-invocation architecture.

12. This does not authorize generic project-context admission. Deterministic
    admission applies only when:
      a. the user message satisfies the bounded explicit Evidence Request
         classifier; and
      b. repository retrieval actually supplied project-context excerpts for
         that invocation.

13. Generic "why" questions, ordinary explanation requests, "tell me more",
    implementation requests, and unrelated uses of the word "evidence" remain
    outside this signal.

Smallest safe implementation unit:

Introduce a new pure classifier:

  isExplicitEvidenceRequest(message: string): boolean

with its own bounded tests.

Wire its boolean result into the existing ollamaChat context without changing
the existing Explanation Request Signal.

When explicitEvidenceRequest is true, Source-Excerpt presentation may
deterministically admit the already-supplied projectContextExcerpts for that
invocation.

Do not alter semantic reply authorship.
Do not add another Ollama invocation.
Do not broaden the Explanation Request Signal.
Do not redefine supportSourceReferences.
Do not redefine evidenceSufficient.
Do not close Evidence Composition until structural and repeated live behavioral
validation confirm deterministic explicit-evidence presentation.

Classification:

DETERMINISTIC_EVIDENCE_REQUEST_SIGNAL_READY

Next implementation unit:

EXPLICIT_EVIDENCE_REQUEST_SIGNAL
FINDINGS
