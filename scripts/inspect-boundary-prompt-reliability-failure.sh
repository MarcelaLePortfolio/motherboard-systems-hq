#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== BOUNDARY COMPOSITION — PROMPT RELIABILITY FAILURE ==="

echo
echo "=== CURRENT STATE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"

echo
echo "=== CURRENT BOUNDED PROMPT CONTRACT ==="
rg -n -C 3 \
'Preserve material uncertainty|Do not surface boundaries|Avoid restating already-established context' \
scripts/utils/ollamaChat.ts

echo
echo "=== PRE-PROMPT LEDGER ==="
sed -n '1,240p' scripts/capture-boundary-composition-evidence-ledger.ts

echo
echo "=== POST-PROMPT LEDGER ==="
sed -n '1,240p' scripts/capture-boundary-composition-post-prompt-ledger.ts

echo
echo "=== INVESTIGATION ==="
cat <<'QUESTION'
Boundary Composition behavioral evidence now establishes:

PRE-PROMPT:
- material scope boundary preserved;
- material unresolved uncertainty preserved;
- authorization boundary preserved;
- unsupported capability boundary preserved;
- immaterial deferred UI redesign surfaced.

A bounded prompt instruction was then added:

"Do not surface boundaries, deferred work, or unresolved limits that do not
materially affect the immediate conclusion or requested answer."

POST-PROMPT:
- material scope boundary preserved;
- material unresolved uncertainty preserved;
- authorization boundary preserved;
- unsupported capability boundary preserved;
- immaterial deferred UI redesign was STILL surfaced.

Therefore the bounded prompt intervention did not resolve the observed semantic
gap.

Investigate the next safe architectural classification without implementing.

Determine:

1. Should this now be classified as an existing-contract/prompt reliability
   failure rather than a missing prompt instruction?

2. Would adding more synonymous prompt wording constitute speculative layering
   under the same failed hypothesis?

3. Would deterministic post-model text filtering be unsafe because deciding
   whether arbitrary natural-language content is immaterial requires semantic
   judgment and could alter Matilda-authored meaning?

4. Is there any existing structured runtime signal that can identify which
   supplied context items are material to the requested answer before reply
   composition?

5. Can supportSourceReferences safely serve that purpose?
   Consider that they identify support provenance for the conclusion,
   recommendation, or assessment, but the failed immaterial example still
   surfaced despite no project_context_excerpt support reference.

6. Does that mismatch suggest a possible bounded semantic-admission seam:
   provide Matilda only context admitted as relevant to the current response,
   rather than attempting to delete immaterial content after generation?

7. Would such an admission seam belong to Boundary Composition, or would it
   improperly begin Adaptive Detail Selection/context selection before that
   corridor is authorized?

8. Is the correct next action therefore:
   - investigate an existing pre-reply relevance/admission seam;
   - introduce structured Boundary state;
   - deterministic post-model filtering;
   - retry prompt-only behavior;
   - or declare Boundary Composition blocked pending Adaptive Detail Selection?

Return exactly one classification:

BOUNDARY_COMPOSITION_PROMPT_RELIABILITY_FAILURE
BOUNDARY_COMPOSITION_PRE_REPLY_ADMISSION_INVESTIGATION_READY
BOUNDARY_COMPOSITION_STRUCTURED_BOUNDARY_INVESTIGATION_READY
BOUNDARY_COMPOSITION_BLOCKED_BY_ADAPTIVE_DETAIL_SELECTION
BOUNDARY_COMPOSITION_NOT_READY

Then identify exactly one smallest next unit.

Do not implement.
Do not add another prompt instruction.
Do not add a second model invocation.
Do not weaken Evidence Composition.
Do not begin Adaptive Detail Selection implementation.
Do not perform post-model semantic filtering.
Preserve Matilda as semantic and Interpretation Authority.
QUESTION
