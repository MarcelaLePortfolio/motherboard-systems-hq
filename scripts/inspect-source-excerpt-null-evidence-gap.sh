#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== SOURCE-EXCERPT-FIRST — NULL EVIDENCE GAP INVESTIGATION ==="

echo
echo "=== CURRENT OUTPUT SCHEMA + PROMPT ==="
sed -n '20,120p' scripts/utils/ollamaChat.ts
sed -n '520,575p' scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT SUPPORT + EVIDENCE VALIDATION ==="
sed -n '590,720p' scripts/utils/ollamaChat.ts

echo
echo "=== LIVE VALIDATOR ==="
cat scripts/validate-source-excerpt-first-live.ts

echo
echo "=== OBSERVED BEHAVIOR ==="
cat <<'OBSERVATION'
Two live runs against the same Source-Excerpt-First validation scenario produced
different valid structured outputs:

RUN A:
- evidence.sources contained the supplied project-context source
- runtime attached the exact supplied excerpt
- SOURCE_EXCERPT_FIRST_LIVE_SUPPORTED

RUN B:
- evidence was null
- overall supportSourceReferences contained only the supplied conversation turn
- evidenceSufficient was true
- SOURCE_EXCERPT_FIRST_LIVE_INCONCLUSIVE

Therefore:

The deterministic excerpt-construction machinery is validated when a
project-context evidence source is selected.

The unresolved gap is whether production Evidence Composition has a reliable,
architecturally valid trigger for selecting project-context evidence when such
evidence materially supports the reply.
OBSERVATION

echo
echo "=== INVESTIGATION REQUEST ==="
cat <<'QUESTION'
Evidence Composition must not be closed while live evidence selection is
nondeterministic in a scenario where supplied project-context evidence directly
answers the user's evidence request.

Do NOT add another prompt-only rule yet.
Do NOT weaken fail-closed validation.
Do NOT treat a null evidence result as successful closure.

Investigate the smallest architecture that resolves this exact gap.

Evaluate these possibilities:

A. MODEL-OWNED EVIDENCE SELECTION
   Keep evidence nullable and continue relying on Ollama to decide whether to
   populate evidence.sources.

   Determine whether this can ever support deterministic corridor closure if the
   same qualifying input may produce either populated evidence or null evidence.

B. OVERALL SUPPORT-DRIVEN CONSTRUCTION
   Keep Ollama as the semantic selector through supportSourceReferences, but
   deterministically construct evidence.sources from validated
   project_context_excerpt references already present in
   supportSourceReferences.

   Determine:
   - whether supportSourceReferences already semantically means "sources that
     explicitly support the conclusion/recommendation/assessment";
   - whether constructing exact excerpts from those validated references adds
     semantic authorship;
   - whether conversation_turn references can simply be ignored by the
     Source-Excerpt-First artifact in this first implementation;
   - whether this removes the need for a separately model-authored evidence
     selection artifact.

C. PROJECT-CONTEXT PRESENCE-DRIVEN CONSTRUCTION
   Deterministically construct evidence from every supplied project-context
   excerpt whenever project context exists.

   Determine whether this would incorrectly present evidence the semantic model
   did not select as supporting its reply.

D. SEPARATE DETERMINISTIC EVIDENCE-REQUEST SIGNAL
   Use the existing explicit explanation/evidence request machinery to decide
   when validated project-context support should be surfaced.

   Determine whether such a signal already exists in the repository and whether
   using it would preserve semantic ownership without introducing a new ontology.

For each determine:

- Does it preserve one Ollama invocation?
- Does it preserve Matilda as semantic/interpretation authority?
- Does it avoid prompt-only enforcement?
- Does it preserve supportSourceReferences semantics?
- Does it preserve Evidence Sufficiency?
- Can behavior be deterministic after the model invocation?
- Does it solve the observed null-evidence live failure?
- Does it require persistence/API/client changes?
- Does it create a second semantic author?

Return exactly one classification:

MODEL_SELECTION_REMAINS_SAFE
SUPPORT_DRIVEN_SOURCE_EXCERPT_READY
PROJECT_CONTEXT_PRESENCE_DRIVEN_READY
DETERMINISTIC_EVIDENCE_REQUEST_SIGNAL_READY
SOURCE_EXCERPT_SELECTION_GAP_NOT_READY

Then identify exactly one smallest next implementation or investigation unit.

Do not implement.
Do not close Evidence Composition.
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
