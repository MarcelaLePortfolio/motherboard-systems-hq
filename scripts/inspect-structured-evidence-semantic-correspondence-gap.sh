#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== STRUCTURED EVIDENCE — SEMANTIC CORRESPONDENCE GAP ==="

echo
echo "=== CURRENT STRUCTURED EVIDENCE CONTRACT ==="
rg -n -C 12 \
'MatildaEvidenceArtifact|evidence:|validatedEvidence|evidence text without support|evidence project-context support' \
scripts/utils/ollamaChat.ts \
scripts/utils/ollamaChat.structured-evidence-object.test.ts

echo
echo "=== LIVE BEHAVIORAL RESULT ==="
cat <<'RESULT'
Observed reply:

Based on the available evidence, it's currently unclear whether the workflow
utilizes the existing Ollama invocation seam.

Observed structured evidence:

text:
  "The repository evidence needs to establish that directly."

supportSourceReferences:
  project_context_excerpt:
    server/matilda-chat-workflow.ts:179

Actual supplied project-context excerpt:

  const ollamaResult = await ollamaChat(message, {

The evidence reference passed deterministic membership validation, but the
evidence text does not state the fact established by that referenced excerpt.
RESULT

echo
echo "=== EXISTING SOURCE-MEMBERSHIP VALIDATION ==="
sed -n '620,760p' scripts/utils/ollamaChat.ts

echo
echo "=== INVESTIGATION REQUEST ==="
cat <<'QUESTION'
Candidate A — the same-invocation structured evidence object — has now passed
structural and source-membership validation but failed its first live semantic
correspondence test.

Do NOT retry prompt-only enforcement.

The precise gap is:

A support reference can be validly supplied and validly referenced while the
model-authored evidence text still does not correspond to what that source
actually establishes.

Determine whether Candidate A can be completed safely without introducing a
second semantic author or another model invocation.

Evaluate these approaches:

A. KEEP CURRENT OBJECT
   evidence: {
     text: string;
     supportSourceReferences: [...]
   }

   Determine whether repository-controlled deterministic logic can actually
   validate semantic correspondence between arbitrary natural-language text and
   a referenced source excerpt. Do not assume source membership equals support.

B. SOURCE-BOUND EVIDENCE OBJECT
   evidence: {
     text: string;
     sources: [{
       reference: MatildaSupportSourceReference;
       suppliedExcerpt: string;
     }]
   }

   Determine whether copying the exact supplied excerpt into the artifact makes
   semantic correspondence deterministically enforceable, or merely improves
   traceability while leaving the same semantic gap.

C. SOURCE-EXCERPT-FIRST ARTIFACT
   evidence: {
     supportSourceReferences: [...];
     sourceExcerpts: [exact supplied source text];
   }

   User-visible evidence would consist only of deterministically verified source
   material; Matilda's ordinary reply remains the semantic interpretation.
   Determine whether this preserves Matilda as Interpretation Authority because
   the workflow is reproducing evidence rather than authoring semantic claims.

D. BOUNDED EVIDENCE ASSERTION
   Replace free-form evidence text with a constrained structured assertion whose
   values can be checked deterministically against source type/identity/content.
   Determine whether a useful bounded assertion vocabulary already exists in the
   repository or would require speculative new ontology.

For each approach determine:

- Can semantic claim-to-source correspondence be deterministically validated?
- Does it preserve one Ollama invocation?
- Does it preserve Matilda as sole semantic author?
- Does it avoid another prompt-only hypothesis?
- Does it preserve Evidence Sufficiency and Support Provenance?
- Does it require a new ontology?
- Does it require client/API changes now?
- Does it solve the exact live failure observed above?

Return exactly one classification:

CURRENT_OBJECT_REMAINS_VIABLE
SOURCE_BOUND_OBJECT_READY
SOURCE_EXCERPT_FIRST_READY
BOUNDED_ASSERTION_READY
CANDIDATE_A_NOT_YET_SAFE

Then identify exactly one smallest next step.

Do not implement.
Do not modify runtime behavior.
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
