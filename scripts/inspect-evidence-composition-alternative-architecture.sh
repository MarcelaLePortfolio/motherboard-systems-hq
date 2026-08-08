#!/usr/bin/env bash
set -euo pipefail

cd "$HOME/Projects/motherboard-systems-hq-clean"

echo "=== EVIDENCE COMPOSITION — ALTERNATIVE ARCHITECTURE INVESTIGATION ==="

echo
echo "=== VERIFIED STABLE BASE ==="
git status --short
echo "BRANCH: $(git branch --show-current)"
echo "HEAD: $(git rev-parse --short HEAD)"
echo "COMMIT: $(git log -1 --format=%s)"
echo
git diff --quiet 5d14fb85 -- . &&
echo "PASS: repository contents match stable checkpoint 5d14fb85."

echo
echo "=== CURRENT STRUCTURED OLLAMA CONTRACT ==="
sed -n '1,180p' scripts/utils/ollamaChat.ts
sed -n '340,430p' scripts/utils/ollamaChat.ts

echo
echo "=== CURRENT WORKFLOW CONSUMPTION ==="
sed -n '145,215p' server/matilda-chat-workflow.ts

echo
echo "=== CURRENT SUPPORT PROVENANCE MODEL ==="
cat server/matilda-support-provenance.ts
echo
cat server/matilda-prior-support-provenance.ts

echo
echo "=== CLIENT RESPONSE BOUNDARY ==="
sed -n '35,70p' client/src/matilda-chat/matildaChatApi.ts
sed -n '70,95p' client/src/matilda-chat/MatildaChatWorkspace.tsx

echo
echo "=== INVESTIGATION REQUEST ==="
cat <<'QUESTION'
Evidence Composition prompt-only enforcement has been abandoned after three
behavioral failures. The repository has been restored to the stable
Reasoning Composition checkpoint.

Investigate a DIFFERENT architectural class.

Constraints:

- Preserve one user message -> one workflow -> one Ollama invocation.
- Preserve Matilda as the sole semantic author.
- Preserve reply / durableInterpretation separation.
- Preserve Evidence Sufficiency and Support Provenance closures.
- Do not retry prompt-only enforcement.
- Do not implement.
- Use repository evidence only.

Evaluate:

A. Same-invocation structured evidence artifact
B. Deterministic post-composition
C. Client-side evidence rendering
D. Workflow-authored evidence sentences

For each determine:

• semantic ownership
• deterministic grounding
• invocation count
• architectural compatibility
• behavioral testability
• persistence implications
• API implications
• whether it resolves the observed behavioral failure

Return exactly one:

STRUCTURED_SAME_INVOCATION_READY
DETERMINISTIC_POST_COMPOSITION_READY
CLIENT_RENDERING_READY
WORKFLOW_EVIDENCE_AUTHORING_READY
NO_SAFE_ALTERNATIVE_CONFIRMED

Then identify the smallest implementation unit.

Do not implement.
QUESTION
